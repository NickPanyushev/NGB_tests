#!/bin/bash

#This script is intended for rebuilding the NGB server from desired git commit 
#and preparing the NGB browser instance for usage and testing

#Reading input arguments

COMMIT=${!#}
REFERENCES=~/ngb_files/references
DATA_FOLDER=~/ngb_files/data_files
NAME=$COMMIT
WORK_DIR=$PWD

if [ -z "$1" ]
then
  echo "No options and parameters found! See help (-h)"
  exit 1
fi

while getopts "n:r:f:p:h" opt
do
  case $opt in
	n) NAME=$OPTARG;;
	r) REFERENCES=$OPTARG;;
	f) DATA_FOLDER=$OPTARG;;
	c) CONFIG=$OPTARG;;
	p) PORT=$OPTARG;;
	h) echo "-n - the shorthand for the commit, for example: merge 2.05.6 "
           echo "-r - the path to reference genomes folder (default is ~/ngb_files/ngb_references/)"
           echo "-f - the folder with test files (default is ~/ngb_files/data_files)"
	   echo "download test files here http://ngb.opensource.epam.com/distr/data/demo/ngb_demo_data.tar.gz"
	   echo "-c - the path to the config file"
           echo "-p - the port to start the catgenome.jar"
	   echo "-h - this help"
	   exit 0 ;;
	*) echo "-h will help you, please look it up"
 	   exit 1;;
  esac
done

#Downloading the desired commit

if [ -d $NAME* ]; then
  read -r -p "This commit seems to exist, remove and redownload it? [y/N]" response
  case "$response" in
    [yY][eE][sS]|[yY])
        sudo rm -rf $WORK_DIR/$NAME/ && echo "Successfully removed"
        echo
	git init
	git clone https://github.com/epam/NGB
	cd NGB
	COMMIT=$(git rev-parse $COMMIT)
	git checkout $COMMIT
	mv ../NGB ../$NAME
	#ls ../$NAME
        ;;
    *)
        echo "Ok, proceeding to building .jar"
        echo
        ;;
  esac
else
  wget https://github.com/epam/NGB/archive/$COMMIT.zip || exit 1
  unzip $COMMIT.zip &> /dev/null && rm $COMMIT.zip
  mv NGB-$COMMIT* $NAME 

fi

#Check if the prebuilded .jar exists
if [ -e $WORK_DIR/$NAME/dist/catgenome.jar ]; then
  read -r -p "Remove existing catgenome.jar and rebuild it?" response
  case "$response" in
      [yY][eE][sS]|[yY])
          sudo rm  $WORK_DIR/$NAME/dist/catgenome.jar && echo "Successfully removed"
          echo
          ;;
      *)
          echo "Nothing was removed"
          echo
          ;;
  esac
fi

#Building the .jar file
if [ ! -e $WORK_DIR/$NAME/dist/catgenome.jar ]; then
  cd $WORK_DIR/$NAME
  echo "Building catgenome.jar"
  ./gradlew buildJar || echo "catgenome.jar BUILD FAILED" exit 1
else
  echo "The existing catgenome.jar will be used"
fi

#Creating the config file

mkdir $WORK_DIR/$NAME/dist/config

if [ ! $CONFIG ]
then
  echo Creating $WORK_DIR/$NAME/dist/config/catgenome.properties with default parameters
  cat << EOF > $WORK_DIR/$NAME/dist/config/catgenome.properties
  files.base.directory.path=~/contents
  database.driver.class=org.h2.Driver
  database.jdbc.url=jdbc:h2:file:~/H2
  database.username=catgenome
  database.password=password
  database.max.pool.size=25
  database.initial.pool.size=5
  file.browsing.allowed=true
  ngs.data.root.path=$DATA_FOLDER
EOF
echo "Config file is successfully created"
echo

else
 echo Copying parameters from $CONFIG file
 cat $CONFIG > $WORK_DIR/$NAME/dist/config/catgenome.properties && echo "Successfully copied"
fi

#Starting the .jar file

if [ ! -z "$PORT" ]
then
    echo "Starting catgenome.jar with the $PORT"
    PORT="--$PORT"
else
    if PORT=$(grep "server.port=*+" $WORK_DIR/$NAME/dist/config/application.properties)
    then
      echo "Starting catgenome.jar with the $PORT"
      PORT="--$PORT"
    fi
    echo "Starting catgenome.jar at the default 8080 port"
    PORT="--server.port=8080"
fi

nohup sudo java -Xmx6G -jar $WORK_DIR/$NAME/dist/catgenome.jar --conf=$WORK_DIR/$NAME/config $PORT &

#Checking the successful start of the jar file

IP=$(ip route get 1.1.1.1 | awk '{print $NF; exit}')
PORT=${PORT: -4}
TIMER=60
while [ $TIMER -gt 0 ]
do
   curl --silent -X GET http://$IP:$PORT/catgenome/version| grep -q "OK" && break
   TIMER=$(($TIMER - 5))
   sleep 5
   [ $TIMER -eq 5 ] && echo "jar start failed" exit 1
done
echo
echo "Jar started successfully"

#Building the CLI
cd $WORK_DIR/$NAME/
echo "Building CLI"
./gradlew buildCli || echo "CLI BUILD FAILED" exit 1
tar -xzvf ./dist/ngb-cli.tar.gz

#Adding cli to $PATH for convenience
export PATH=$WORK_DIR/$NAME/ngb-cli/bin/:$PATH
echo

#Now let's register references and data files

if [ ! -e ngb_reg_files.sh ]; then #Check for presence of the next script file
  echo "No script ngb_reg_files.sh found! Please put this file in working folder"
  exit 1
fi

source ./ngb_reg_files.sh
exit 0

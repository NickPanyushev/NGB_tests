import subprocess
import argparse
import os
import sys
import platform
import ctypes
import shutil

jarProcess = None

def killJar():
	if platform.system() == 'Windows':
		#win32api.TerminateProcess(int(jarProcess._handle), -1)
		ctypes.windll.kernel32.TerminateProcess(int(jarProcess._handle), -1)
	else:
		jarProcess.kill()


def runCommand(args):
	print(" ".join(args))
	exitcode = subprocess.call(args)
	if exitcode != 0:
		print("Something went wrong, exit code {0}".format(exitcode))
		killJar()
		sys.exit(1)

def runCommandBackgroundS(args):
	_args = args.split(" ")
	print(args)
	return subprocess.Popen(_args)

def runCommandS(args):
	_args = args.split(" ")
	print(args)
	exitcode = subprocess.call(_args)
	if exitcode != 0:
		print("Something went wrong, exit code {0}".format(exitcode))
		killJar()
		sys.exit(1)

def runNgbCommand(command):
	_args = command.split(" ")
	ngb_command = None
	if (platform.system() == 'Windows'):
		ngb_command = "ngb.bat"
	else:
		ngb_command = "ngb"
	args = [ngb_command]
	args.extend(_args)
	runCommand(args)


# def runDockerCommand(args):
# 	_args = ["docker", "exec", container_name]
# 	_args.extend(args)
# 	runCommand(_args)	

# def runDockerCommandS(args):
# 	_args = ["docker", "exec", container_name]
# 	_args.extend(args.split(" "))
# 	runCommand(_args)

parser = argparse.ArgumentParser(description='Runs Test pipeline')
parser.add_argument('repo_url', metavar='REPOSITORY', help='Repository URL')
parser.add_argument('test_data_folder', metavar='TEST_DATA_FOLDER', help='Location of test data root folder')
parser.add_argument('--branch', metavar='BRANCH', help='Specify branch to build from')
args = parser.parse_args()
#"git@git.epam.com:epm-cmbi/ngb.git"

currDir = os.getcwd()
if not os.path.isdir(os.path.join(currDir, 'ngb')):
	exitcode = subprocess.call(["git", "clone", args.repo_url])
	if exitcode != 0:
		print("Something went wrong, exit code {0}".format(exitcode))
		sys.exit(1)


os.chdir(os.path.join(currDir, 'ngb'))

branch = args.branch if args.branch is not None else 'master' 
runCommand(["git", "checkout", branch])

runCommand(["git", "pull", "origin", branch])

if platform.system() == 'Linux':
	runCommand(["chmod", "+x", "gradlew"])
	#runCommand(["./gradlew", "buildCli", "buildJar"])
	runCommand(["./gradlew", "buildCli"])
else:
    runCommand(["gradlew.bat", "buildCli", "buildJar"])

os.chdir(os.path.join(currDir, 'ngb/dist'))
jarProcess = runCommandBackgroundS("java -jar catgenome.jar")
runCommandS("jar xf ngb-cli.zip")

if platform.system() == 'Linux':
	runCommand(["chmod", "+x", "ngb-cli/bin/ngb"])

test_root = args.test_data_folder
#/mnt/nfsshare

os.chdir(os.path.join(currDir, 'ngb/dist/ngb-cli/bin'))
is_running = False
while not is_running:
	ngb_command = None
	if (platform.system() == 'Windows'):
		ngb_command = "ngb.bat"
	else:
		ngb_command = "ngb"
	args = [ngb_command]
	args.extend(["reg_ref", test_root + "/Homo_sapiens.GRCh38.fa.gz", "--name", "GRCh38"])
	
	print("Attempting " +" ".join(args))
	_exitcode = subprocess.call(args)
	if _exitcode == 0:
		is_running = True

#runCommand(["ngb-cli/bin/ngb", "reg_ref", test_root + "/Homo_sapiens.GRCh38.fa.gz", "--name", "GRCh38"])
runNgbCommand("reg_file GRCh38 {0}/Homo_sapiens.GRCh38.gtf.gz --name GRCh38_Genes".format(test_root))
runNgbCommand("ag GRCh38 GRCh38_Genes")

runNgbCommand("reg_ref {0}/dmel-all-chromosome-r6.06.fasta.gz --name DM6".format(test_root))
runNgbCommand("reg_file DM6 {0}/dmel-all-r6.06.sorted.gtf.gz --name DM6_Genes".format(test_root))
runNgbCommand("ag DM6 DM6_Genes")

runNgbCommand("reg_file GRCh38 {0}/sample_1-lumpy.vcf".format(test_root))
runNgbCommand("reg_file GRCh38 {0}/ngb_demo_data/sv_sample_1.bw".format(test_root))
runNgbCommand("reg_file GRCh38 {0}/ngb_demo_data/sv_sample_1.bam?{0}/ngb_demo_data/sv_sample_1.bam.bai".format(test_root))
runNgbCommand("rd GRCh38 SV_Sample1")
runNgbCommand("add SV_Sample1 sample_1-lumpy.vcf")
runNgbCommand("add SV_Sample1 sv_sample_1.bw")
runNgbCommand("add SV_Sample1 sv_sample_1.bam")

runNgbCommand("reg_file GRCh38 {0}/ngb_demo_data/sample_2-lumpy.vcf".format(test_root))
runNgbCommand("reg_file GRCh38 {0}/ngb_demo_data/sv_sample_2.bw".format(test_root))
runNgbCommand("reg_file GRCh38 {0}/ngb_demo_data/sv_sample_2.bam?{0}/ngb_demo_data/sv_sample_2.bam.bai".format(test_root))
runNgbCommand("rd GRCh38 SV_Sample2")
runNgbCommand("add SV_Sample2 sample_2-lumpy.vcf")
runNgbCommand("add SV_Sample2 sv_sample_2.bw")
runNgbCommand("add SV_Sample2 sv_sample_2.bam")

runNgbCommand("reg_file GRCh38 {0}/ngb_demo_data/PIK3CA-E545K.vcf".format(test_root))
runNgbCommand("reg_file GRCh38 {0}/ngb_demo_data/PIK3CA-E545K.bam?{0}/ngb_demo_data/PIK3CA-E545K.bam.bai".format(test_root))
runNgbCommand("rd GRCh38 PIK3CA-E545K-Sample")
runNgbCommand("add PIK3CA-E545K-Sample PIK3CA-E545K.vcf")
runNgbCommand("add PIK3CA-E545K-Sample PIK3CA-E545K.bam")

runNgbCommand("reg_file GRCh38 {0}/ngb_demo_data/brain_th.bam?{0}/ngb_demo_data/brain_th.bam.bai".format(test_root))
runNgbCommand("rd GRCh38 RNASeq-chr22-SpliceJunctions")
runNgbCommand("add RNASeq-chr22-SpliceJunctions brain_th.bam")

runNgbCommand("reg_file GRCh38 {0}/ngb_demo_data/FGFR3-TACC-Fusion.vcf")
runNgbCommand("reg_file GRCh38 {0}/ngb_demo_data/FGFR3-TACC-Fusion.bam?{0}/ngb_demo_data/FGFR3-TACC-Fusion.bam.bai".format(test_root))
runNgbCommand("rd GRCh38 FGFR3-TACC-Fusion-Sample")
runNgbCommand("add FGFR3-TACC-Fusion-Sample FGFR3-TACC-Fusion.vcf")
runNgbCommand("add FGFR3-TACC-Fusion-Sample FGFR3-TACC-Fusion.bam")

runNgbCommand("reg_file DM6 {0}/ngb_demo_data/agnX1.09-28.trim.dm606.realign.vcf".format(test_root))
runNgbCommand("reg_file DM6 {0}/ngb_demo_data/agnX1.09-28.trim.dm606.realign.bam?{0}/ngb_demo_data/agnX1.09-28.trim.dm606.realign.bai".format(test_root))
runNgbCommand("reg_file DM6 {0}/ngb_demo_data/CantonS.09-28.trim.dm606.realign.vcf".format(test_root))
runNgbCommand("reg_file DM6 {0}/ngb_demo_data/CantonS.09-28.trim.dm606.realign.bam?{0}/ngb_demo_data/CantonS.09-28.trim.dm606.realign.bai".format(test_root))
runNgbCommand("reg_file DM6 {0}/ngb_demo_data/agnts3.09-28.trim.dm606.realign.vcf".format(test_root))
runNgbCommand("reg_file DM6 {0}/ngb_demo_data/agnts3.09-28.trim.dm606.realign.bam?{0}/ngb_demo_data/agnts3.09-28.trim.dm606.realign.bai".format(test_root))
runNgbCommand("rd DM6 Fruitfly")
runNgbCommand("add Fruitfly agnX1.09-28.trim.dm606.realign.vcf")
runNgbCommand("add Fruitfly agnX1.09-28.trim.dm606.realign.bam")
runNgbCommand("add Fruitfly CantonS.09-28.trim.dm606.realign.vcf")
runNgbCommand("add Fruitfly CantonS.09-28.trim.dm606.realign.bam")
runNgbCommand("add Fruitfly agnts3.09-28.trim.dm606.realign.vcf")
runNgbCommand("add Fruitfly agnts3.09-28.trim.dm606.realign.bam")

# ## cloning tests
os.chdir(currDir)
if not os.path.isdir(os.path.join(currDir, 'ngb2-qa.git')):
	runCommand(["git", "clone", "git@git.epam.com:epm-cmbi/ngb2-qa.git"])

os.chdir(os.path.join(currDir, 'ngb2-qa'))
runCommand(["git", "checkout", "master"])
runCommand(["mvn", "clean", "test", "-P", "chrome_test", "-e"])

killJar()

os.chdir(currDir)
shutil.rmtree(os.path.join(currDir, 'ngb/dist'))

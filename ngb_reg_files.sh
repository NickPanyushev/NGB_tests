#!/bin/bash

#This script registers the ngb test data
#And this code is referenced from the main script ngb_test.sh

REFERENCES=~/ngb_files/references
DATA_FOLDER=~/ngb_files/data_files

#Let's register naked species at first
ngb rs Human GRCh38
ngb rs Human GRCh37
ngb rs Human hg19
ngb rs Mouse GRCm38
ngb rs Drosophila DM6

echo "Registering GRCh38 reference"
ngb reg_ref $REFERENCES/Homo_sapiens.GRCh38.fasta --species GRCh38 --name GRCh38 &&
ngb reg_file GRCh38 $REFERENCES/Homo_sapiens.GRCh38.gtf --name GRCh38_Genes &&
ngb ag GRCh38 GRCh38_Genes &&
ngb reg_file GRCh38 $REFERENCES/Homo_sapiens.GRCh38.domains.bed --name GRCh38_Domains &&
ngb an GRCh38 GRCh38_Domains &&
echo "GRCh38 reference and annotation were succesfully registered" ||
echo "Something with GRCh38 reference has gone wrong, please check paths and filenames"
#ngb add_spec GRCh38 GRCh38

#Registering D.melanogaster reference
ngb reg_ref $REFERENCES/dmel-all-chromosome-r6.06.fasta --species DM6 --name DM6 &&
ngb reg_file DM6 $REFERENCES/dmel-all-r6.06.sorted.gtf --name DM6_Genes &&
ngb ag DM6 DM6_Genes &&
echo "GRCh38 reference and annotation were succesfully registered" ||
echo "Something with DM6 reference has gone wrong, please check paths and filenames"
#ngb add_spec "DM6" "DM6"

#Registering hg19, GRC37, GRCm38 references
#ngb reg_ref $REFERENCES/hg19.fa --name hg19 --species Human && ngb add_spec "hg19" "hg19" &&  echo "Success with hg19" || echo "hg19 fail"
ngb reg_ref $REFERENCES/hg19.fa --name hg19 --species hg19 && echo "Success with hg19" || echo "hg19 fail"

#ngb reg_ref $REFERENCES/hs37d5.fa --name GRCh37 --species Human && ngb add_spec "GRCh37" "GRCh37" && echo "Success with GRCh37" || echo "GRCh37 fail"
ngb reg_ref $REFERENCES/hs37d5.fa --name GRCh37 --species GRCh37 && echo "Success with GRCh37" || echo "GRCh37 fail"

#ngb reg_ref $REFERENCES/Mus_musculus.GRCm38.fa --name GRCm38 --species Mouse && ngb add_spec "GRCm38" "GRCm38" && echo "Success with GRCm38" || echo "GRCm38 fail"
ngb reg_ref $REFERENCES/Mus_musculus.GRCm38.fa --name GRCm38 --species GRCm38 && echo "Success with GRCm38" || echo "GRCm38 fail"

#Now let's register datasets and separate files
cd $DATA_FOLDER/ngb_demo_data
ngb rd GRCh38 SV_Sample1
ngb add SV_Sample1 sample_1-lumpy.vcf
ngb add SV_Sample1 sv_sample_1.bw
ngb add SV_Sample1 sv_sample_1.bam
ngb reg_file GRCh38 sample_2-lumpy.vcf
ngb reg_file GRCh38 sv_sample_2.bw
ngb reg_file GRCh38 sv_sample_2.bam

ngb rd GRCh38 SV_Sample2
ngb add SV_Sample2 sample_2-lumpy.vcf
ngb add SV_Sample2 sv_sample_2.bw
ngb add SV_Sample2 sv_sample_2.bam

ngb reg_file GRCh38 PIK3CA-E545K.vcf
ngb reg_file GRCh38 PIK3CA-E545K.bam
ngb reg_file GRCh38 PIK3CA-E545K.cram?PIK3CA-E545K.cram.crai

ngb rd GRCh38 PIK3CA-E545K-Sample
ngb add PIK3CA-E545K-Sample PIK3CA-E545K.vcf
ngb add PIK3CA-E545K-Sample PIK3CA-E545K.bam
ngb add PIK3CA-E545K-Sample PIK3CA-E545K.cram
ngb reg_file GRCh38 brain_th.bam?brain_th.bam.bai

ngb rd GRCh38 RNASeq-chr22-SpliceJunctions
ngb add RNASeq-chr22-SpliceJunctions brain_th.bam

ngb reg_file GRCh38 FGFR3-TACC-Fusion.vcf
ngb reg_file GRCh38 FGFR3-TACC-Fusion.bam
ngb rd GRCh38 FGFR3-TACC-Fusion-Sample
ngb add FGFR3-TACC-Fusion-Sample FGFR3-TACC-Fusion.vcf
ngb add FGFR3-TACC-Fusion-Sample FGFR3-TACC-Fusion.bam

ngb reg_file DM6 agnX1.09-28.trim.dm606.realign.vcf
ngb reg_file DM6 agnX1.09-28.trim.dm606.realign.bam?agnX1.09-28.trim.dm606.realign.bai
ngb reg_file DM6 CantonS.09-28.trim.dm606.realign.vcf
ngb reg_file DM6 CantonS.09-28.trim.dm606.realign.bam?CantonS.09-28.trim.dm606.realign.bai
ngb reg_file DM6 agnts3.09-28.trim.dm606.realign.vcf
ngb reg_file DM6 agnts3.09-28.trim.dm606.realign.bam?agnts3.09-28.trim.dm606.realign.bai

ngb rd DM6 Fruitfly
ngb add Fruitfly agnX1.09-28.trim.dm606.realign.vcf
ngb add Fruitfly agnX1.09-28.trim.dm606.realign.bam
ngb add Fruitfly CantonS.09-28.trim.dm606.realign.vcf
ngb add Fruitfly CantonS.09-28.trim.dm606.realign.bam
exit 0

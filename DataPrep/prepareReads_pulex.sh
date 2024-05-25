#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N prepData_pulex_jobOutput

# script to perform data pre-processing and prepare RNAseq reads for analysis
# usage: qsub prepareReads_pulex.sh

# set input paths
pulexInPath="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_pulex/PA42_trans"

# retrieve output paths
pulexOutPath=$(grep "pairedReads:" ../"InputData/inputPaths_pulex.txt" | tr -d " " | sed "s/pairedReads://g")

# create output directories
mkdir $pulexOutPath
#Check if the folder already exists
if [ $? -ne 0 ]; then
	echo "The $pulexOutPath directory already exsists... please remove before proceeding."
	exit 1
fi

# status message
echo "Beginning data prep ..."

# find truncated files with incomplete reads
#for i in $pulexInPath"/"*.fq; do echo $i; less $i | tail -4 | head -1 | grep -v "@"; done

# create folder to backup data
mkdir $pulexOutPath"/tmp"

# clean up truncated files and remove incomplete reads
# Ni_2_1.fq
cp $pulexInPath"/Ni_2_1.fq" $pulexOutPath"/tmp/Ni_2_1.fq"
tail -n -1 $pulexOutPath"/tmp/Ni_2_1.fq" > $pulexInPath"/Ni_2_1.fq"
# pH_3_2.fq
cp $pulexInPath"/pH_3_2.fq" $pulexOutPath"/tmp/pH_3_2.fq"
tail -n -1 $pulexOutPath"/tmp/pH_3_2.fq" > $pulexInPath"/pH_3_2.fq"
# pH_4_2.fq
cp $pulexInPath"/pH_4_2.fq" $pulexOutPath"/tmp/pH_4_2.fq"
tail -n -2 $pulexOutPath"/tmp/pH_4_2.fq" > $pulexInPath"/pH_4_2.fq"

# pulex
# read 1
for i in $pulexInPath"/"*_1.fq; do 
	# setup output name
	outName=$(basename $i | sed "s/_1\.fq/_1\.fq\.gz/g")
	# status message
	echo "Processing $outName ..."
	# rename files for read 1
	gzip < $i > $pulexOutPath"/"$outName
done
# read 2
for i in $pulexInPath"/"*_2.fq; do 
	# setup output name
	outName=$(basename $i | sed "s/_2\.fq/_2\.fq\.gz/g")
	# status message
	echo "Processing $outName ..."
	# rename files for read 2
	gzip < $i > $pulexOutPath"/"$outName
done

# status message
echo "Data prep completed!"

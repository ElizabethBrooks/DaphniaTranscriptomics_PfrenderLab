#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N prepData_pulex_jobOutput

# script to perform data pre-processing and prepare RNAseq reads for analysis
# usage: qsub prepareReads_pulex.sh

# set input paths
pulexInPathOne="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_pulex/PA42_trans"

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

# pulex
# read 1
for i in $pulexInPathOne"/"*_1.fq; do 
	# setup output name
	outName=$(basename $i | sed "s/_1\.fq/_1\.fq\.gz/g")
	# status message
	echo "Processing $outName ..."
	# rename files for read 1
	mv $i $pulexOutPath"/"$outName
done
# read 2
for i in $pulexInPathOne"/"*_2.fq; do 
	# setup output name
	outName=$(basename $i | sed "s/_2\.fq/_2\.fq\.gz/g")
	# status message
	echo "Processing $outName ..."
	# rename files for read 2
	mv $i $pulexOutPath"/"$outName
done

# status message
echo "Data prep completed!"

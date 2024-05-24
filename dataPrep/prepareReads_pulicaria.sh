#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N prepData_pulicaria_jobOutput

# script to perform data pre-processing and prepare RNAseq reads for analysis
# usage: qsub prepareReads_pulicaria.sh

# set input paths
pulicariaInPathOne="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_pulicaria/D_pulicaria_Lk16_Transcriptome/Lk16_Pool1"
pulicariaInPathTwo="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_pulicaria/D_pulicaria_Lk16_Transcriptome/Lk16_Pool2"

# retrieve output paths
pulicariaOutPath=$(grep "pairedReads:" ../"inputData/inputPaths_pulicaria.txt" | tr -d " " | sed "s/pairedReads://g")

# create output directories
mkdir $pulicariaOutPath

# status message
echo "Beginning data prep ..."

# pulicaria
# data set 1
# read 1
for i in $pulicariaInPathOne"/"*; do 
	# setup output name
	outName=$(ls $i"/"*_R1_*.fastq.gz | head -1)
	outName=$(basename $outName | sed "s/_001//g")
	# status message
	echo "Processing $outName ..."
	# combine files for read 1
	cat $i"/"*_R1_*.fastq.gz > $pulicariaOutPath"/"$outName
done
# read 2
for i in $pulicariaInPathOne"/"*; do 
	# setup output name
	outName=$(ls $i"/"*_R2_*.fastq.gz | head -1)
	outName=$(basename $outName | sed "s/_001//g")
	# status message
	echo "Processing $outName ..."
	# combine files for read 2
	cat $i"/"*_R2_*.fastq.gz  > $pulicariaOutPath"/"$outName
done
# data set 2
# read 1
for i in $pulicariaInPathTwo"/"*; do 
	# setup output name
	outName=$(ls $i"/"*_R1_*.fastq.gz | head -1)
	outName=$(basename $outName | sed "s/_001\.fastq/\.fq/g")
	# status message
	echo "Processing $outName ..."
	# combine files for read 1
	cat $i"/"*_R1_*.fastq.gz > $pulicariaOutPath"/"$outName
done
# read 2
for i in $pulicariaInPathTwo"/"*; do 
	# setup output name
	outName=$(ls $i"/"*_R2_*.fastq.gz | head -1)
	outName=$(basename $outName | sed "s/_001\.fastq/\.fq/g")
	# status message
	echo "Processing $outName ..."
	# combine files for read 2
	cat $i"/"*_R2_*.fastq.gz  > $pulicariaOutPath"/"$outName
done

# status message
echo "Data prep completed!"

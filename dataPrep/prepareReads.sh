#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N prepData_projects_jobOutput

# script to perform data pre-processing and prepare RNAseq reads for analysis
# usage: bash prepareReads.sh

# set input paths
obtusaInPathOne="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_obtusa/D_obtusa_multi/multi_condition_BGI_DNBSeq/F20FTSUSAT1134_DAPfhqR/RawData"
obtusaInPathTwo="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_obtusa/D_obtusa_multi/multi_condition_BGI_DNBSeq/F20FTSUSAT1134_DAPltkR/RawData/"
pulicariaInPath="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_pulicaria/D_pulicaria_Lk16_Transcriptome/Lk16_Pool1"

# retrieve output paths
obtusaOutPath=$(grep "pairedReads:" ../"inputData/inputPaths_obtusa.txt" | tr -d " " | sed "s/pairedReads://g")
pulicariaOutPath=$(grep "pairedReads:" ../"inputData/inputPaths_pulicaria.txt" | tr -d " " | sed "s/pairedReads://g")

# create output directories
mkdir $obtusaOutPath
mkdir $pulicariaOutPath

# status message
echo "Beginning data prep ..."

# obtusa
# read 1
for i in $obtusaInPathOne"/"*/*_1.fq.gz; do 
	# setup output name
	outName=$(basename $i)
	# status message
	echo "Processing $outName ..."
	# retrieve input name
	inName=$(basename $i | sed "s/_1\.fq\.gz//g" | sed "s/_/-/g")
	# combine files for read 1
	cat $i $obtusaInPathTwo"/"$inName"/"*_1.fq.gz > $obtusaOutPath"/"$outName
done
# read 2
for i in $obtusaInPathOne"/"*/*_2.fq.gz; do 
	# setup output name
	outName=$(basename $i)
	# status message
	echo "Processing $outName ..."
	# retrieve input name
	inName=$(basename $i | sed "s/_2\.fq\.gz//g" | sed "s/_/-/g")
	# combine files for read 2
	cat $i $obtusaInPathTwo"/"$inName"/"*_2.fq.gz > $obtusaOutPath"/"$outName
done

# pulicaria
# read 1
for i in $pulicariaInPath"/"*; do 
	# setup output name
	outName=$(ls $i"/"*_R1_*.fastq.gz | head -1)
	outName=$(basename $outName | sed "s/_001//g")
	# status message
	echo "Processing $outName ..."
	# combine files for read 1
	cat $i"/"*_R1_*.fastq.gz > $pulicariaOutPath"/"$outName
done
# read 2
for i in $pulicariaInPath"/"*; do 
	# setup output name
	outName=$(ls $i"/"*_R2_*.fastq.gz | head -1)
	outName=$(basename $outName | sed "s/_002//g")
	# status message
	echo "Processing $outName ..."
	# combine files for read 2
	cat $i"/"*_R2_*.fastq.gz > $pulicariaOutPath"/"$outName
done

# status message
echo "Data prep completed!"

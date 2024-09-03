#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N download_SRA_EGAPx_jobOutput
#$ -pe smp 8

# script to download formatted SRA reads for EGAPx
# usage: qsub download_SRA_reads_EGAPx.sh species ID
# usage ex: qsub download_SRA_reads_EGAPx.sh LK16 DRP002580
# usage ex: qsub download_SRA_reads_EGAPx.sh LK16 SRP068113
# usage ex: qsub download_SRA_reads_EGAPx.sh LK16 SRP102491
# usage ex: qsub download_SRA_reads_EGAPx.sh LK16 SRP253589
# usage ex: qsub download_SRA_reads_EGAPx.sh LK16 SRP318178

# retrieve input species
inputSpecies=$2

# retrieve input SRA ID
inputID=$2

# retrieve software path
softwarePath=$(grep "software_SRA:" ../"inputData/inputPaths.txt" | tr -d " " | sed "s/software_SRA://g")

# retrieve outputs path
outputsPath=$(grep "outputs_SRA:" ../"inputData/inputPaths.txt" | tr -d " " | sed "s/outputs_SRA://g")

# name species outputs directory
outDir=$outputsPath"/dump_"$inputSpecies

# make species directory for the formatted data
mkdir $outDir

# move to species directory, since SRA tools caches data in the working directory
cd $outDir

# name SRA ID outputs directory
outDir=$outDir"/"$inputID

# make SRA ID directory for the formatted data
mkdir $outDir

# download formated reads
prefetch $inputID

# loop over each SRA ID retrieved using prefetch
for i in $outDir"/"*"/"; do
	$softwarePath"/"fasterq-dump --skip-technical --threads 8 --split-files --seq-defline ">\$ac.\$si.\$ri" --fasta -O $outDir"/"  ./$i
done

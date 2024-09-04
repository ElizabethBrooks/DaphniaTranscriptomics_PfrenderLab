#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N download_SRA_EGAPx_jobOutput
#$ -pe smp 8

# script to download formatted SRA reads for EGAPx
# usage: qsub download_SRA_reads_EGAPx.sh species ID
# usage ex: qsub download_SRA_reads_EGAPx.sh LK16 DRP002580
## job 793225, 793310, 793317
# usage ex: qsub download_SRA_reads_EGAPx.sh LK16 SRP068113
## job 793230, 793322, 793422
# usage ex: qsub download_SRA_reads_EGAPx.sh LK16 SRP102491
## job 793231, 793324
# usage ex: qsub download_SRA_reads_EGAPx.sh LK16 SRP253589
## job 793232, 793325
# usage ex: qsub download_SRA_reads_EGAPx.sh LK16 SRP318178
## job 793234, 793326

# retrieve input species
inputSpecies=$1

# retrieve input SRA ID
inputID=$2

# retrieve software path
softwarePath=$(grep "software_SRA:" ../../"inputData/inputs_annotations.txt" | tr -d " " | sed "s/software_SRA://g")

# retrieve outputs path
outputsPath=$(grep "outputs_SRA:" ../../"inputData/inputs_annotations.txt" | tr -d " " | sed "s/outputs_SRA://g")

# name species outputs directory
outDir=$outputsPath"/dump_"$inputSpecies

# make species directory for the formatted data
mkdir $outDir

# name SRA ID outputs directory
outDir=$outDir"/dump_"$inputID

# make SRA ID directory for the formatted data
mkdir $outDir

# move to outputs directory, since SRA tools caches data in the working directory
cd $outDir

# download formated reads
prefetch $inputID

# status message
echo "Beginning analysis..."

# loop over each SRA ID retrieved using prefetch
for i in $outDir"/"*"/"; do
	# retrieve SRA ID
	sraID=$(basename $i)
	# status message
	echo "Processing $sraID ..."
	# retrieve SRA data
	$softwarePath"/"fasterq-dump --skip-technical --threads 8 --split-files --seq-defline ">\$ac.\$si.\$ri" --fasta -O $outDir"/"  ./$sraID
done

# status message
echo "Analysis complete!"

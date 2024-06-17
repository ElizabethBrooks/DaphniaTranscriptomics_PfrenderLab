#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N search_blastp_jobOutput
#$ -pe smp 8

# script to use blastp to search a protein file 
# usage: qsub search_blastp.sh queryFile dbFolder outputFolder outputFile doneFlag

# load necessary modules for ND CRC servers
module load bio/2.0

# retrieve input paths
queryFile=$1
dbFolder=$2

# retrieve output paths
outputFolder=$3
outputFile=$4

# retrieve analysis done flag
doneFlag=$5

# move to output folder
cd $outputFolder

# status message
echo "Beginning within genome blastp search..."

# perform the protein blast search for the single best hits
blastp -num_threads 8 -outfmt 6 -evalue 1e-5 -max_target_seqs 1 -query $queryFile -db $dbFolder -out $outputFile

if [[ $doneFlag == "YES" ]]; then
	# NOTE: only run this script after the previous commands have completed running and the blast outputs have finished being created
	bash find_RBH.sh $outputFolder"/"$firstSpecies"_"$secondSpecies".blast" $outputFolder"/"$secondSpecies"_"$firstSpecies".blast"
fi

# status message
echo "Analysis complete!"

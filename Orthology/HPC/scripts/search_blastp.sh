#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N search_blastp_jobOutput
#$ -pe smp 8

# script to use blastp to search a protein file 
# usage: qsub search_blastp.sh queryFile dbFolder outputFolder outputFile

# load necessary modules for ND CRC servers
module load bio/2.0

# retrieve input paths
queryFile=$1
dbFolder=$2

# retrieve output paths
outputFolder=$3
outputFile=$4

# move to output folder
cd $outputFolder

# status message
echo "Beginning within genome blastp search..."

# perform the protein blast search for the single best hits
blastp -num_threads 8 -outfmt 6 -evalue 1e-5 -max_target_seqs 1 -query $queryFile -db $dbFolder -out $outputFile

# status message
echo "Analysis complete!"

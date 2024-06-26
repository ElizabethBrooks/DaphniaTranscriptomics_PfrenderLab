#!/bin/bash

# script to use blastp to search a protein file against a blastable database
# usage: bash search_blastp.sh queryFile dbFolder outputFile

# retrieve input paths
queryFile=$1
dbFolder=$2

# retrieve output paths
outputFile=$3

# status message
echo "Beginning within genome blastp search..."

# perform the protein blast search for the single best hits
blastp -num_threads 4 -outfmt 6 -evalue 1e-5 -max_target_seqs 1 -query $queryFile -db $dbFolder -out $outputFile

# status message
echo "Search complete!"

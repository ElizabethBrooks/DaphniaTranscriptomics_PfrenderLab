#!/bin/bash

# script to use blastp to search a protein file against a blastable database
# usage: bash search_blastp.sh queryFile dbFolder outputFolder outputFile numAlign

# retrieve input paths
queryFile=$1
dbFolder=$2

# retrieve output paths
outputFolder=$3
outputFile=$4

# retrieve input number of alignments for blastp
numAlign=$5

# status message
echo "Beginning within genome blastp search..."

# perform the protein blast search for the single best hits
blastp -num_threads 4 -outfmt 6 -evalue 1e-5 -max_target_seqs 1 -query $queryFile -db $dbFolder -num_alignments $numAlign -out $outputFile

# status message
echo "Search complete!"

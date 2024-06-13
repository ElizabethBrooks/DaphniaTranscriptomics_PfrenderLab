#!/bin/bash

# script to build a blast able database 
# usage: bash makeDB_blastp.sh speciesPep outputFolder

# retrieve input paths
speciesPep=$1

# retrieve output paths
outputFolder=$2

# status message
echo "Building blast able databases..."

# 15. Build the BLASTP database and place it in the ‘ncbiDB’ folder.
makeblastdb -in $speciesPep -out $outputFolder -dbtype prot

# status message
echo "Analysis complete!"

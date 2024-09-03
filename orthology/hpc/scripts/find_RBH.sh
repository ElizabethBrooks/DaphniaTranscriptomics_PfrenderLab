#!/bin/bash

# script to filter blast results files for reciprocal best hits (RBH)
# Usage: bash find_RBH.sh firstBlast secondBlast

# retrieve input file paths
firstBlast=$1
secondBlast=$2

# setup output file paths
outputProt=$(echo $firstBlast | sed "s/\.blast/_RBH_proteins.csv/g")
outputGenes=$(echo $firstBlast | sed "s/\.blast/_RBH_genes.csv/g")

# retrieve blastp comparison tags
comparison=$(basename $firstBlast | sed "s/\.blast//g")

# add header in csv format
echo $comparison | sed "s/_/,/g" > $outputProt

# status message
echo "Finding RBHs..."

# loop over first set of annotations
while IFS=$'\t' read -r f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12
do
	# determine annotation sets
	if grep -q "$f2"$'\t'"$f1"$'\t' $secondBlast; then #RBH
		echo "$f1,$f2" >> $outputProt
	fi
done < $firstBlast

# convert transcript IDs to gene IDs and remove duplicate entries
cat $outputProt | sed "s/\.t.//g" | awk -F, '!seen[$1]++' | awk -F, '!seen[$2]++' > $outputGenes

# status message
echo "RBHs Found!"

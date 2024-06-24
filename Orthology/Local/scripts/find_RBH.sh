#!/bin/bash

# script to filter blast results files for reciprocal best hits (RBH)
# Usage: bash find_RBH.sh firstBlast secondBlast

# retrieve input file paths
firstBlast=$1
secondBlast=$2

# setup output file path
outputFile=$(echo $firstBlast | sed "s/\.blast/_RBH.csv/g")

# retrieve blastp comparison tags
firstComparison=$(basename $firstBlast | sed "s/\.blast//g")
secondComparison=$(basename $secondBlast | sed "s/\.blast//g")

# add header in csv format
echo $firstComparison | sed "s/_/,/g" > $outputFile

# status message
echo "Finding RBHs..."

# loop over first set of annotations
while IFS=$'\t' read -r f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12
do
	# determine annotation sets
	if grep -q "$f2"$'\t'"$f1"$'\t' $secondBlast; then #RBH
		echo "$f1,$f2" >> $outputFile
	fi
done < $firstBlast

# status message
echo "RBHs Found!"

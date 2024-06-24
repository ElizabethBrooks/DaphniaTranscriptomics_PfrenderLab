#!/bin/bash

# pipeline driver script to build a blastable database, perform blastp searches, and find RBHs
# usage: bash search_pipeline_blastp.sh

# load necessary modules for ND CRC servers
module load bio/2.0

# retrieve species tags
firstSpecies="pulicaria"
secondSpecies="obtusa"

# retrieve inputs
firstPep=$(grep "proteins:" ../../InputData/inputPaths_pulicaria.txt | tr -d " " | sed "s/proteins://g")
secondPep=$(grep "proteins:" ../../InputData/inputPaths_obtusa.txt | tr -d " " | sed "s/proteins://g")

# retrieve outputs directory
outputFolder=$(grep "outputs:" ../../InputData/inputPaths_pulicaria.txt | tr -d " " | sed "s/outputs://g")

# setup outputs directory two levels up in the tree
outputFolder=$(dirname $outputFolder)
outputFolder=$(dirname $outputFolder)
outputFolder=$outputFolder"/orthology_RBHB"

# make output directory
mkdir $outputFolder

# setup outputs subdirectory
outputFolder=$outputFolder"/"$firstSpecies"_"$secondSpecies

# make output subdirectory
mkdir $outputFolder

# move to the scripts directory
cd scripts

# status message
echo "Beginning search pipeline..."

# make the first blast able database
bash makeDB_blastp.sh $firstPep $outputFolder"/"$firstSpecies"_db"

# make the second blast able database
bash makeDB_blastp.sh $secondPep $outputFolder"/"$secondSpecies"_db"

# perform the first protein blast search for the single best hits
qsub search_blastp.sh $firstPep $outputFolder"/"$secondSpecies"_db" $outputFolder $outputFolder"/"$firstSpecies"_"$secondSpecies".blast"

# perform the second protein blast search for the single best hits
qsub search_blastp.sh $secondPep $outputFolder"/"$firstSpecies"_db" $outputFolder $outputFolder"/"$secondSpecies"_"$firstSpecies".blast"

# status message
echo "Search pipeline running!"

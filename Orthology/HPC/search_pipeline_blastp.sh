#!/bin/bash

# pipeline driver script to build a blastable database, perform blastp searches, and find RBHs
# usage: bash search_pipeline_blastp.sh

# load necessary modules for ND CRC servers
module load bio/2.0

# retrieve species tags
firstSpecies=$(grep "firstSpecies:" ../../InputData/inputPaths_RBHB_HPC.txt | tr -d " " | sed "s/firstSpecies://g")
secondSpecies=$(grep "secondSpecies:" ../../InputData/inputPaths_RBHB_HPC.txt | tr -d " " | sed "s/secondSpecies://g")

# retrieve inputs
firstPep=$(grep "firstPep:" ../../InputData/inputPaths_RBHB_HPC.txt | tr -d " " | sed "s/firstPep://g")
secondPep=$(grep "secondPep:" ../../InputData/inputPaths_RBHB_HPC.txt | tr -d " " | sed "s/secondPep://g")

# retrieve outputs directory
outputFolder=$(grep "outputs:" ../../InputData/inputPaths_RBHB_HPC.txt | tr -d " " | sed "s/outputs://g")

# setup outputs directory
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

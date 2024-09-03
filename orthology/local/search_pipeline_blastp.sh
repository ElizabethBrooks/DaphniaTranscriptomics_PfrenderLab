#!/bin/bash

# pipeline driver script to build a blastable database, perform blastp searches, and find RBHs
# usage: bash search_pipeline_blastp.sh

# retrieve species tags
firstSpecies="pulicaria"
secondSpecies="obtusa"

# retrieve species tags
firstSpecies=$(grep "firstSpecies:" ../../inputData/inputs_RBHB_HPC.txt | tr -d " " | sed "s/firstSpecies://g")
secondSpecies=$(grep "secondSpecies:" ../../inputData/inputs_RBHB_HPC.txt | tr -d " " | sed "s/secondSpecies://g")

# retrieve inputs
firstPep=$(grep "firstPep:" ../../inputData/inputs_RBHB_HPC.txt | tr -d " " | sed "s/firstPep://g")
secondPep=$(grep "secondPep:" ../../inputData/inputs_RBHB_HPC.txt | tr -d " " | sed "s/secondPep://g")

# retrieve outputs directory
outputFolder=$(grep "outputs:" ../../inputData/inputs_RBHB_HPC.txt | tr -d " " | sed "s/outputs://g")

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
bash search_blastp.sh $firstPep $outputFolder"/"$secondSpecies"_db" $outputFolder"/"$firstSpecies"_"$secondSpecies".blast"

# perform the second protein blast search for the single best hits
bash search_blastp.sh $secondPep $outputFolder"/"$firstSpecies"_db" $outputFolder"/"$secondSpecies"_"$firstSpecies".blast"

# NOTE: only run this script after the previous commands have completed running and the blast outputs have finished being created
bash find_RBH.sh $outputFolder"/"$firstSpecies"_"$secondSpecies".blast" $outputFolder"/"$secondSpecies"_"$firstSpecies".blast"

# status message
echo "Search pipeline complete!"

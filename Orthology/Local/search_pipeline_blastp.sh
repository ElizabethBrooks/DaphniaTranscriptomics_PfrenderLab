#!/bin/bash

# script to use blastp to search to build a blast file for MCScanX 
# usage: bash search_pipeline_blastp.sh

# retrieve species tags
firstSpecies="pulicaria"
secondSpecies="obtusa"

# retrieve inputs
firstPep=$(grep "pulicariaPep:" ../InputData/inputs_local.txt | tr -d " " | sed "s/pulicariaPep://g")
secondPep=$(grep "obtusaPep:" ../InputData/inputs_local.txt | tr -d " " | sed "s/obtusaPep://g")

# setup outputs directory
outputFolder=$(grep "outputs:" ../InputData/inputs_local.txt | tr -d " " | sed "s/outputs://g")
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
echo "Beginning analysis..."

# make the first blast able database
bash makeDB_blastp.sh $firstPep $outputFolder"/"$firstSpecies"_db"

# make the second blast able database
bash makeDB_blastp.sh $secondPep $outputFolder"/"$secondSpecies"_db"

# perform the first protein blast search for the single best hits
bash search_blastp.sh $firstPep $outputFolder"/"$secondSpecies"_db" $outputFolder $outputFolder"/"$firstSpecies"_"$secondSpecies".blast" 5

# perform the second protein blast search for the single best hits
bash search_blastp.sh $secondPep $outputFolder"/"$firstSpecies"_db" $outputFolder $outputFolder"/"$secondSpecies"_"$firstSpecies".blast" 5

# NOTE: only run this script after the previous commands have completed running and the blast outputs have finished being created
bash find_RBH.sh $outputFolder"/"$firstSpecies"_"$secondSpecies".blast" $outputFolder"/"$secondSpecies"_"$firstSpecies".blast"

# status message
echo "Analysis complete!"

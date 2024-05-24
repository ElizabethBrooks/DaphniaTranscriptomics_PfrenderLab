#!/bin/bash

# script to perform data pre-processing and prepare RNAseq reads for analysis
# usage: bash prepareReads.sh

# set input paths
obtusaInPathOne="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_obtusa/D_obtusa_multi/multi_condition_BGI_DNBSeq/F20FTSUSAT1134_DAPfhqR/RawData"
obtusaInPathTwo="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_obtusa/D_obtusa_multi/multi_condition_BGI_DNBSeq/F20FTSUSAT1134_DAPltkR/RawData/"
pulicariaInPath="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_pulicaria/D_pulicaria_Lk16_Transcriptome/Lk16_Pool1"

# retrieve output paths
obtusaOutPath=$(grep "pairedReads:" ../"inputData/inputPaths_obtusa.txt" | tr -d " " | sed "s/pairedReads://g")
pulicariaOutPath=$(grep "pairedReads:" ../"inputData/inputPaths_pulicaria.txt" | tr -d " " | sed "s/pairedReads://g")

# obtusa
for i in $obtusaInPathOne"/"*/*_1.fq.gz; do outName=$(basename $i); inName=$(basename $i | sed "s/_1\.fq\.gz//g" | sed "s/_/-/g"); cat $i $obtusaInPathTwo"/"$inName"/"*_1.fq.gz > $obtusaOutPath"/"$outName; done
for i in $obtusaInPathOne"/"*/*_2.fq.gz; do outName=$(basename $i); inName=$(basename $i | sed "s/_2\.fq\.gz//g" | sed "s/_/-/g"); cat $i $obtusaInPathTwo"/"$inName"/"*_2.fq.gz > $obtusaOutPath"/"$outName; done

# pulicaria
for i in $pulicariaInPath"/"*; do outName=$(ls $i"/"*_R1_*.fastq.gz | head -1); outName=$(basename $outName | sed "s/_001//g"); cat $i"/"*_R1_*.fastq.gz > $pulicariaOutPath"/"$outName; done
for i in $pulicariaInPath"/"*; do outName=$(ls $i"/"*_R2_*.fastq.gz | head -1); outName=$(basename $outName | sed "s/_002//g"); cat $i"/"*_R2_*.fastq.gz > $pulicariaOutPath"/"$outName; done

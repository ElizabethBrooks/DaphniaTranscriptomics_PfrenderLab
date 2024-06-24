#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N multiqc_raw_daphniaOmics_jobOutput

# script to perform fastqc quality control of paired end reads
# usage: qsub multiqc_raw_daphniaOmics.sh inputsFile
# usage Ex: qsub multiqc_raw_daphniaOmics.sh inputPaths_obtusa.txt
# usage Ex: qsub multiqc_raw_daphniaOmics.sh inputPaths_pulicaria.txt
# usage Ex: qsub multiqc_raw_daphniaOmics.sh inputPaths_pulex.txt

# retrieve input argument of a inputs file
inputsFile=$1

# retrieve paired reads absolute path for alignment
readPath=$(grep "pairedReads:" ../"InputData/"$inputsFile | tr -d " " | sed "s/pairedReads://g")
# retrieve analysis outputs absolute path
outputsPath=$(grep "outputs:" ../"InputData/"$inputsFile | tr -d " " | sed "s/outputs://g")

# make a new directory for analysis
qcOut=$outputsPath"/qc_raw"

# move to the new directory
cd $qcOut

# name output file of inputs
inputOutFile=$qcOut"/pipeline_summary.txt"
versionFile=$qcOut"/version_summary.txt"
# peport software version
multiqc --version >> $versionFile

# run multiqc
multiqc $qcOut

#Print status message
echo "Analysis complete!"

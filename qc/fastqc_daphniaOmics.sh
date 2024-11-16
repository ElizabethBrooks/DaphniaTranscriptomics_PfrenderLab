#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N fastqc_daphniaOmics_jobOutput
#$ -pe smp 8

# script to perform fastqc quality control of paired end reads
# usage: qsub fastqc_daphniaOmics.sh inputsFile analysisType
# usage Ex: qsub fastqc_daphniaOmics.sh inputs_obtusa.txt raw
# usage Ex: qsub fastqc_daphniaOmics.sh inputs_pulicaria.txt raw
# usage Ex: qsub fastqc_daphniaOmics.sh inputs_obtusa.txt trimmed
# usage Ex: qsub fastqc_daphniaOmics.sh inputs_pulicaria.txt trimmed

# required modules for ND CRC servers
module load bio/2.0

# retrieve input argument of a inputs file
inputsFile=$1

# retrieve input analysis type
analysisType=$2

# retrieve analysis outputs absolute path
outputsPath=$(grep "outputs:" ../"inputData/"$inputsFile | tr -d " " | sed "s/outputs://g")

# check input analysis type
if [[ $analysisType == "raw" ]]; then
	# retrieve raw paired reads absolute path for alignment
	readPath=$(grep "pairedReads:" ../"inputData/"$inputsFile | tr -d " " | sed "s/pairedReads://g")
else
	# retrieve trimmed reads path
	readPath=$outputsPath"/trimmed"
fi

# create output results directory
mkdir $outputsPath
#Check if the folder already exists
if [ $? -ne 0 ]; then
	echo "The $outputsPath directory already exsists... please remove before proceeding."
	exit 1
fi

# make a new directory for analysis
qcOut=$outputsPath"/qc_"$analysisType
mkdir $qcOut
#Check if the folder already exists
if [ $? -ne 0 ]; then
	echo "The $qcOut directory already exsists... please remove before proceeding."
	exit 1
fi

# move to the new directory
cd $qcOut

# name output version file
versionFile=$qcOut"/version_summary.txt"

# report software version
fastqc -version > $versionFile

# status message
echo "Beginning QC..."

# run fastqc on all reads
fastqc -t 8 $readPath"/"*fq.gz; do

# status message
echo "Analysis complete!"

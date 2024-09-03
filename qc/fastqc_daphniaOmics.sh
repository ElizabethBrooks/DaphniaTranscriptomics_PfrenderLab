#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N fastqc_daphniaOmics_jobOutput

# script to perform fastqc quality control of paired end reads
# usage: qsub fastqc_daphniaOmics.sh inputsFile analysisType
# usage Ex: qsub fastqc_daphniaOmics.sh inputPaths_obtusa.txt raw
# usage Ex: qsub fastqc_daphniaOmics.sh inputPaths_pulicaria.txt raw
# usage Ex: qsub fastqc_daphniaOmics.sh inputPaths_obtusa.txt trimmed
# usage Ex: qsub fastqc_daphniaOmics.sh inputPaths_pulicaria.txt trimmed

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

#Make a new directory for analysis
qcOut=$outputsPath"/qc_"$analysisType
mkdir $qcOut
#Check if the folder already exists
if [ $? -ne 0 ]; then
	echo "The $qcOut directory already exsists... please remove before proceeding."
	exit 1
fi

#Move to the new directory
cd $qcOut

#Name output file of inputs
inputOutFile=$qcOut"/pipeline_summary.txt"
versionFile=$qcOut"/version_summary.txt"
#Report software version
fastqc -version > $versionFile

#Loop through all forward and reverse reads and run trimmomatic on each pair
for f1 in "$readPath"/*fq.gz; do
	#Trim path from file name
	noPath=$(basename $f1 | sed 's/\.fq\.gz//')
	#Trim extension from current file name
	curSample=$(echo $f1 | sed 's/\.fq\.gz//')
	#Set paired file name
	f2=$curSample"_2.fq.gz"
	#Print status message
	echo "Processing $noPath"
	#Perform QC on both paired end reads for the current sample
	fastqc $f1 -o $qcOut --extract
	fastqc $f2 -o $qcOut --extract
	#Output run inputs
	echo "fastqc $f1 -o $qcOut --extract" >> $inputOutFile
	echo "fastqc $f2 -o $qcOut --extract" >> $inputOutFile
	#Print status message
	echo "Processed!"
done

#Print status message
echo "Analysis complete!"

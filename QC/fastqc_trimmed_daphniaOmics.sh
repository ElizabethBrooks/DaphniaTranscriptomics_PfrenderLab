#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N fastqc_trimmed_daphniaOmics_jobOutput

# script to perform fastqc quality control of paired end reads
# usage: qsub fastqc_trimmed_daphniaOmics.sh inputsFile
# usage Ex: qsub fastqc_trimmed_daphniaOmics.sh inputPaths_obtusa.txt
# usage Ex: qsub fastqc_trimmed_daphniaOmics.sh inputPaths_pulicaria.txt
# usage Ex: qsub fastqc_trimmed_daphniaOmics.sh inputPaths_pulex.txt

#Required modules for ND CRC servers
module load bio/2.0

#Retrieve input argument of a inputs file
inputsFile=$1

#Retrieve analysis outputs absolute path
outputsPath=$(grep "outputs:" ../"InputData/"$inputsFile | tr -d " " | sed "s/outputs://g")
outputsPath=$outputsPath"/trimmed"

#Make a new directory for analysis
qcOut=$(dirname $outputsPath
qcOut=$qcOut"/qc_trimmed"
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
for f1 in "$outputsPath"/*fq.gz; do
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

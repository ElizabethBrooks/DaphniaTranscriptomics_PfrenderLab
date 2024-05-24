#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N fastqc_daphniaOmics_jobOutput

#Script to perform fastqc quality control of paired end reads
#Usage: qsub fastqc_daphniaOmics.sh inputsFile
#Usage Ex: qsub fastqc_daphniaOmics.sh inputPaths_obtusa.txt
#Usage Ex: qsub fastqc_daphniaOmics.sh inputPaths_pulicaria.txt
#Usage Ex: qsub fastqc_daphniaOmics.sh inputPaths_pulex.txt

#Required modules for ND CRC servers
module load bio/2.0

#Retrieve input argument of a inputs file
inputsFile=$1

#Retrieve paired reads absolute path for alignment
readPath=$(grep "pairedReads:" ../"InputData/"$inputsFile | tr -d " " | sed "s/pairedReads://g")
#Retrieve analysis outputs absolute path
outputsPath=$(grep "outputs:" ../"InputData/"$inputsFile | tr -d " " | sed "s/outputs://g")

# create output results directory
mkdir $outputsPath
#Check if the folder already exists
if [ $? -ne 0 ]; then
	echo "The $outputsPath directory already exsists... please remove before proceeding."
	exit 1
fi

#Make a new directory for analysis
qcOut=$outputsPath"/qc"
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
for f1 in "$readPath"/*_1.fq.gz; do
	#Trim path from file name
	noPath=$(basename $f1 | sed 's/_1\.fq\.gz//')
	#Trim extension from current file name
	curSample=$(echo $f1 | sed 's/_1\.fq\.gz//')
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

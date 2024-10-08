#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N trimmomatic_PE_daphniaOmics_jobOutput
#$ -pe smp 8

# script to perform trimmomatic trimming of paired end reads
# usage: qsub trimmomatic_PE_daphniaOmics.sh inputsFile
# usage Ex: qsub trimmomatic_PE_daphniaOmics.sh inputs_obtusa.txt
# usage Ex: qsub trimmomatic_PE_daphniaOmics.sh inputs_pulicaria.txt

#Required modules for ND CRC servers
module load bio/2.0

#Retrieve input argument of a inputs file
inputsFile=$1

#Retrieve paired reads absolute path for alignment
readPath=$(grep "pairedReads:" ../"inputData/"$inputsFile | tr -d " " | sed "s/pairedReads://g")
#Retrieve adapter absolute path for alignment
adapterPath=$(grep "adapter:" ../"inputData/"$inputsFile | tr -d " " | sed "s/adapter://g")
#Retrieve analysis outputs absolute path
outputsPath=$(grep "outputs:" ../"inputData/"$inputsFile | tr -d " " | sed "s/outputs://g")

#Make a new directory for analysis
trimOut=$outputsPath"/trimmed"
mkdir $trimOut
#Check if the folder already exists
if [ $? -ne 0 ]; then
	echo "The $trimOut directory already exsists... please remove before proceeding."
	exit 1
fi
#Move to the new directory
cd $trimOut

#Name output file of inputs
inputOutFile=$outputsPath"/pipeline_summary.txt"
versionFile=$outputsPath"/version_summary.txt"

#Add software version to outputs
echo "Trimmomatic:" >> $versionFile
trimmomatic -version >> $versionFile

# retrieve a sample file
testFile=$(ls $outputsPath"/qc/"*_1_fastqc/fastqc_data.txt | head -1)

#Determine phred score for trimming
if grep -iF "Illumina 1.5" $testFile; then
	score=64
elif grep -iF "Illumina 1.9" $testFile; then
	score=33
else
	echo "ERROR: Illumina encoding not found... exiting"
	exit 1
fi

#Loop through all forward and reverse reads and run trimmomatic on each pair
for f1 in $readPath"/"*_1.fq.gz; do
	#Trim extension from current file name
	curSample=$(echo $f1 | sed 's/_1\.fq\.gz//')
	#Set paired file name
	f2=$curSample"_2.fq.gz"
	#Trim to sample tag
	sampleTag=$(basename $f1 | sed 's/_1\.fq\.gz//')
	#Print status message
	echo "Processing $sampleTag"
	#Perform adapter trimming on paired reads
	trimmomatic PE -threads 8 -phred"$score" $f1 $f2 $sampleTag"_pForward.fq.gz" $sampleTag"_uForward.fq.gz" $sampleTag"_pReverse.fq.gz" $sampleTag"_uReverse.fq.gz" ILLUMINACLIP:"$adapterPath":2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:60 HEADCROP:10
	#Add run inputs to output summary file
	echo trimmomatic PE -threads 8 -phred"$score" $f1 $f2 $sampleTag"_pForward.fq.gz" $sampleTag"_uForward.fq.gz" $sampleTag"_pReverse.fq.gz" $sampleTag"_uReverse.fq.gz" ILLUMINACLIP:"$adapterPath":2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:60 HEADCROP:10 >> $inputOutFile
	#Print status message
	echo "Processed!"
done

#Print status message
echo "Analysis complete!"

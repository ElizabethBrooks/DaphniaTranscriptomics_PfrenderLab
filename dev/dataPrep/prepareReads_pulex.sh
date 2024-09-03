#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N prepData_pulex_jobOutput

# script to perform data pre-processing and prepare RNAseq reads for analysis
# usage: qsub prepareReads_pulex.sh

# set input paths
pulexInPath="/afs/crc.nd.edu/group/pfrenderlab/mendel/ebrooks/Daphnia_RNAseq/D_pulex/PA42_trans"

# retrieve output paths
pulexOutPath=$(grep "pairedReads:" ../"inputData/inputs_pulex.txt" | tr -d " " | sed "s/pairedReads://g")

# create output directories
mkdir $pulexOutPath
#Check if the folder already exists
if [ $? -ne 0 ]; then
	echo "The $pulexOutPath directory already exsists... please remove before proceeding."
	exit 1
fi

# status message
echo "Beginning data prep ..."

# find truncated files with incomplete reads
#for i in $pulexInPath"/"*.fq; do echo $i; less $i | tail -4 | head -1 | grep -v "@"; done

# create folder to backup data
mkdir $pulexInPath"/backup"

# clean up truncated files and remove incomplete reads
# remove the last line from Ni_2_1.fq
mv $pulexInPath"/Ni_2_1.fq" $pulexInPath"/backup/Ni_2_1.fq"
sed '$d' $pulexInPath"/backup/Ni_2_1.fq" > $pulexInPath"/Ni_2_1.fq"
# remove the last line from pH_3_2.fq
mv $pulexInPath"/pH_3_2.fq" $pulexInPath"/backup/pH_3_2.fq"
sed '$d' $pulexInPath"/backup/pH_3_2.fq" > $pulexInPath"/pH_3_2.fq"
# remove the last two lines from pH_4_2.fq
mv $pulexInPath"/pH_4_2.fq" $pulexInPath"/backup/pH_4_2.fq"
sed '$d' $pulexInPath"/backup/pH_4_2.fq" | sed '$d' > $pulexInPath"/pH_4_2.fq"

# pulex
# read 1
for i in $pulexInPath"/"*_1.fq; do 
	# setup output name
	outName=$(basename $i | sed "s/\.fq/\.fq\.gz/g")
	# status message
	echo "Processing $outName ..."
	# compress and rename files for read 1
	gzip < $i > $pulexOutPath"/"$outName
done
# read 2
for i in $pulexInPath"/"*_2.fq; do 
	# setup output name
	outName=$(basename $i | sed "s/\.fq/\.fq\.gz/g")
	# status message
	echo "Processing $outName ..."
	# compress and rename files for read 2
	gzip < $i > $pulexOutPath"/"$outName
done

# status message
echo "Data prep completed!"

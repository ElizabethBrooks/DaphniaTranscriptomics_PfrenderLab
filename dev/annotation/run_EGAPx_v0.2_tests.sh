#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N run_EGAPx_v0.2_tests_jobOutput
#$ -q long
#$ -pe smp 63

# script to run the EGAPx pipeline
# usage: qsub run_EGAPx_v0.2_tests.sh inputFile
# usage ex: qsub run_EGAPx_v0.2_tests.sh inputs_LK16_NCBI_test1.txt
## job 793426 -> SUCCEEDED
## job 795141 -> ABORTED
## job 795680 -> SUCCEEDED
## Duration    : 12h 8m 27s
## CPU hours   : 762.5
## Succeeded   : 234
## CDS          143899
## exon         153207
## gene         22122
## mRNA         20831
## transcript   2548
# usage ex: qsub run_EGAPx_v0.2_tests.sh inputs_LK16_trimmed_test1.txt
## job 793458, 793856 -> SUCCEEDED
## job 795142 -> ABORTED
## job 795681 -> SUCCEEDED
## Duration    : 10h 48m 12s
## CPU hours   : 678.7
## Succeeded   : 214
## CDS          150685
## exon         166752
## gene         19764
## mRNA         20322
## transcript   3169
# usage ex: qsub run_EGAPx_v0.2_tests.sh inputs_LK16_NCBI_test2.txt
## job 794884 -> ABORTED
## job 795682 -> SUCCEEDED
## Duration    : 12h 16m 21s
## CPU hours   : 770.8
## Succeeded   : 234
## CDS          143899
## exon         153207
## gene         22122
## mRNA         20831
## transcript   2548
# usage ex: qsub run_EGAPx_v0.2_tests.sh inputs_LK16_trimmed_test2.txt
## job 794885 -> ABORTED
## job 795683 -> SUCCEEDED
## Duration    : 10h 50m 38s
## CPU hours   : 681.2
## Succeeded   : 214
## CDS          150685
## exon         166752
## gene         19764
## mRNA         20322
## transcript   3169
# usage ex: qsub run_EGAPx_v0.2_tests.sh inputs_LK16_trimmed_test3.txt
## job 796720 -> SUCCEEDED
## Duration    : 10h 41m 49s
## CPU hours   : 671.6
## Succeeded   : 218
## CDS          150685
## exon         166752
## gene         19764
## mRNA         20322
## transcript   3169
# usage ex: qsub run_EGAPx_v0.2_tests.sh inputs_LK16_trimmed_test4.txt

# NOTE: the default /egapx/ui/assets/config/process_resources.config file specifies up to 31 cores (huge_Job)
# our afs system has 263Gb RAM, 64 cores
# make sure to always leave 1 core free for general processes, so request up to 63 cores per job on our afs system

# retrieve input file
inputFile=$1

# retrieve species name
speciesName=$(grep "species:" ../"inputData/"$inputFile | tr -d " " | sed "s/species://g")

# retrieve inputs path
inputsPath=$(grep "inputs_EGAPx:" ../"inputData/"$inputFile | tr -d " " | sed "s/inputs_EGAPx://g")

# retrieve repository directory
repoDir=$(dirname $PWD)

# setup inputs path
inputsPath=$repoDir"/inputData/"$inputsPath

# retrieve software path
softwarePath=$(grep "software_EGAPx_v0.2:" ../"inputData/inputs_annotations_test.txt" | tr -d " " | sed "s/software_EGAPx_v0.2://g")

# retrieve outputs path
outputsPath=$(grep "outputs_EGAPx_v0.2_tests:" ../"inputData/inputs_annotations_test.txt" | tr -d " " | sed "s/outputs_EGAPx_v0.2_tests://g")

# setup outputs directory
outputsPath=$outputsPath"/"$speciesName

# make outputs directory
mkdir $outputsPath

# make temporary data path
mkdir $outputsPath"/temp_datapath"

# move to outputs directory
cd $outputsPath

# status message
echo "Beginning analysis of $speciesName..."

# run EGAPx to copy config files
python3 $softwarePath"/ui/egapx.py" $inputsPath -e singularity -w $outputsPath"/temp_datapath" -o $outputsPath

# run EGAPx
python3 $softwarePath"/ui/egapx.py" $inputsPath -e singularity -w $outputsPath"/temp_datapath" -o $outputsPath

# clean up, if accept.gff output file exsists
if [ ! -f $outputsPath"/accept.gff" ]; then
	# run to resume annotation
	sh $outputsPath"/resume.sh"
else
    rm -r $outputsPath"/temp_datapath"
	rm -r $outputsPath"/work"
	rm -r $outputsPath"/annot_builder_output"
fi

# status message
echo "Analysis of $speciesName complete!"

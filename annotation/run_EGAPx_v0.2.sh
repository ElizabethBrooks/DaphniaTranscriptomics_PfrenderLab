#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N run_EGAPx_v0.2_jobOutput
#$ -pe smp 63

# script to run the EGAPx pipeline
# usage: qsub run_EGAPx_v0.2.sh inputFile
# usage ex: qsub run_EGAPx_v0.2.sh inputs_LK16_NCBI.txt
# usage ex: qsub run_EGAPx_v0.2.sh inputs_LK16_trimmed.txt

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
softwarePath=$(grep "software_EGAPx_v0.2:" ../"inputData/inputs_annotations.txt" | tr -d " " | sed "s/software_EGAPx_v0.2://g")

# retrieve outputs path
outputsPath=$(grep "outputs_EGAPx_v0.2:" ../"inputData/inputs_annotations.txt" | tr -d " " | sed "s/outputs_EGAPx_v0.2://g")

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

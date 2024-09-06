#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N run_EGAPx_v0.1_tests_jobOutput
#$ -q long
#$ -pe smp 63

# script to run the EGAPx pipeline
# usage: qsub run_EGAPx_v0.1_tests.sh inputFile
# usage ex: qsub run_EGAPx_v0.1_tests.sh inputs_LK16_NCBI_test1.txt
## job 794912 -> ERROR ~ index is out of range 0..-1 (index = 0)
## job 795134 -> ABORTED
## job 795684 -> ERROR ~ index is out of range 0..-1 (index = 0)
# usage ex: qsub run_EGAPx_v0.1_tests.sh inputs_LK16_trimmed_test1.txt
## job 794913 -> ERROR ~ index is out of range 0..-1 (index = 0)
## job 795135 -> ABORTED
## job 795685 -> ERROR ~ index is out of range 0..-1 (index = 0)
# usage ex: qsub run_EGAPx_v0.1_tests.sh inputs_LK16_NCBI_test2.txt
## job 794915 -> ABORTED
## job 795686 -> SUCCEEDED
# usage ex: qsub run_EGAPx_v0.1_tests.sh inputs_LK16_trimmed_test2.txt
## job 794916 -> ERROR ~ index is out of range 0..-1 (index = 0)
## job 795136 -> ABORTED
## job 795687 -> ERROR ~ index is out of range 0..-1 (index = 0)
# usage ex: qsub run_EGAPx_v0.1_tests.sh inputs_LK16_trimmed_test3.txt
## job 796721 -> ERROR ~ index is out of range 0..-1 (index = 0)

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
softwarePath=$(grep "software_EGAPx_v0.1:" ../"inputData/inputs_annotations_test.txt" | tr -d " " | sed "s/software_EGAPx_v0.1://g")

# retrieve outputs path
outputsPath=$(grep "outputs_EGAPx_v0.1_tests:" ../"inputData/inputs_annotations_test.txt" | tr -d " " | sed "s/outputs_EGAPx_v0.1_tests://g")

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
	# run nextflow to resume annotation
	nextflow -C $outputsPath"/egapx_config/singularity.config",$softwarePath"/ui/assets/config/default.config",$softwarePath"/ui/assets/config/docker_image.config",$softwarePath"/ui/assets/config/process_resources.config" \
		-log $outputsPath"/nextflow.log" run $softwarePath"/ui/"../nf/ui.nf \
		--output $outputsPath \
		-with-report $outputsPath"/run.report.html" \
		-with-timeline $outputsPath"/run.timeline.html" \
		-with-trace $outputsPath"/run.trace.txt" \
		-params-file $outputsPath"/run_params.yaml"
		- resume
else
    rm -r $outputsPath"/temp_datapath"
	rm -r $outputsPath"/work"
	rm -r $outputsPath"/annot_builder_output"
fi

# status message
echo "Analysis of $speciesName complete!"

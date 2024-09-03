#!/bin/bash

# script to create a multiqc report
# usage: bash multiqc_daphniaOmics.sh inputsFile analysisType
# usage Ex: bash multiqc_daphniaOmics.sh inputs_obtusa.txt raw
# usage Ex: bash multiqc_daphniaOmics.sh inputs_pulicaria.txt raw
# usage Ex: bash multiqc_daphniaOmics.sh inputs_obtusa.txt trimmed
# usage Ex: bash multiqc_daphniaOmics.sh inputs_pulicaria.txt trimmed

# retrieve input argument of a inputs file
inputsFile=$1

# retrieve input analysis type
analysisType=$2

# retrieve analysis outputs absolute path
outputsPath=$(grep "outputs:" ../"inputData/"$inputsFile | tr -d " " | sed "s/outputs://g")

# retrieve directory for analysis
qcOut=$outputsPath"/qc_"$analysisType

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

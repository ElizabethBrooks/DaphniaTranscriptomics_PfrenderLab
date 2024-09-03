#!/bin/bash

# script to install and test run the EGAPx pipeline
# https://github.com/ncbi/egapx?tab=readme-ov-file
# usage: bash install_EGAPx.sh

# retrieve software path
softwarePath=$(grep "software_EGAPx:" ../"inputData/inputs_annotations.txt" | tr -d " " | sed "s/software_EGAPx://g")

# move to software path
cd $softwarePath

# Install Nextflow
pip install nextflow

# Clone the EGAPx repo
git clone https://github.com/ncbi/egapx.git
cd egapx

# Create a virtual environment where you can run EGAPx. There is a requirements.txt file. PyYAML will be installed in this environment
#python -m venv $softwarePath"/"EGAPx_env
#source $softwarePath"/"EGAPx_env/bin/activate

# install pyYAML
pip install -r ui/requirements.txt

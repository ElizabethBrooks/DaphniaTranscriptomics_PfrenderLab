#!/bin/bash

# script to install and test run the BRAKER3 pipeline
# https://hub.docker.com/r/teambraker/braker3
# usage: bash install_BRAKER3.sh

# retrieve software path
softwarePath=$(grep "software_BRAKER3:" ../"inputData/inputs_annotations.txt" | tr -d " " | sed "s/software_BRAKER3://g")

# move to software path
cd $softwarePath

# For Singularity, build the sif-file as follows
singularity build braker3.sif docker://teambraker/braker3:latest

# Execute BRAKER like this (i.e. it automatically mounts the user's home directory on the host system)
singularity exec braker3.sif braker.pl

# make test directory
mkdir "BRAKER3_test"

# move to test directory
cd "BRAKER3_test"

# We provide 3 test scripts for the singularity container. They can be copied to the host as follows
singularity exec -B $softPath:$softPath $softPath"/"braker3.sif cp /opt/BRAKER/example/singularity-tests/test1.sh .
singularity exec -B $softPath:$softPath $softPath"/"braker3.sif cp /opt/BRAKER/example/singularity-tests/test2.sh .
singularity exec -B $softPath:$softPath $softPath"/"braker3.sif cp /opt/BRAKER/example/singularity-tests/test3.sh .

# They can be executed with bash. Prior running them, you need to export two bash environment variables on the host
export BRAKER_SIF=$softPath"/braker3.sif"

# After that, execute with
bash test1.sh # tests BRAKER1
bash test2.sh # tests BRAKER2
bash test3.sh # tests BRAKER3

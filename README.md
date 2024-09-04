# DaphniaTranscriptomics_PfrenderLab

This is a repository with code for analyzing Daphnia omics data.

## Genome Annotation - [EGAPx](https://github.com/ncbi/egapx/) Workflows
The workflow for EGAPx is setup for job submission to the ND CRC remote servers.

Note that singularity needs to be installed on your system. The ND CRC servers already have singularity available.

### Installation
The <i>install_EGAPx.sh</i> script in the <b>install</b> directory can be used to install EGAPx and its dependencies. 

Make sure to change the paths in the <i>inputs_annotations.txt</i> file to where you would like to have the software installed and outputs generated.

### Notes
There are some things to keep in mind when running EGAPx.

#### EGAPx Config
The <i>egapx/ui/assets/config/process_resources.config</i> file specifies up to 31 cores (huge_Job).

The ND CRC [system specifications](https://docs.crc.nd.edu/new_user/quick_start.html) indicates that our afs system has 263Gb RAM, 64 cores. Make sure to leave 1 core free for general processes, so request up to 63 cores per job on our afs system.

The <i>EGAPx_v0.2_process_resources.config</i> file in the <i>inputData</i> directory may be used to run EGAPx workflow jobs on the ND CRC remote servers.

#### inputData

##### reads
The read files need to be formatted very specifically, see the format_SRA_reads_EGAPx.sh and download_SRA_reads_EGAPx.sh scripts in the Formatting directory. This is because EGAPx expects that input "reads" are a list of FASTA read files, expects pairs in form SRAxxx.1, SRAxxx.2 (see the egapx/nf/./subworkflows/ncbi/./rnaseq_short/star_wnode/main.nf file).

##### reads_ids
There is a limit to the number of SRA IDs that can be input to EGAPx, since the pipeline makes a query to the SRA. The HTTP header becomes too large if the list of SRA IDs is very long. 

###### NCBI Data Sets
These IDs can be retrieved from the annotation report pages of each species. For example, [KAP4 NCBI annotation report](https://www.ncbi.nlm.nih.gov/refseq/annotation_euk/Daphnia_pulex/100/). These are the "RNA-Seq alignments" "Project" IDs and the "SRA Long Read Alignment Statistics" "Run" ID. The unique Project IDs are being used since EGAPx fails if the HTTP header becomes to large from a long list of samples.

# DaphniaTranscriptomics_PfrenderLab

## Genome Annotation

### [EGAPx](https://github.com/ncbi/egapx/) Workflows
The workflow for EGAPx is setup for job submission to the ND CRC remote servers.

Note that singularity needs to be installed on your system. The ND CRC servers already have singularity available.

#### Installation
The <i>install_EGAPx.sh</i> script in the <b>install</b> directory can be used to install EGAPx and its dependencies. 

Make sure to change the paths in the <i>inputs_annotations.txt</i> file to where you would like to have the software installed and outputs generated.

#### Notes
There are some things to keep in mind when running EGAPx.

##### Running
- Either the number of cores requested for a job must be at least 31, or you will need to edit the default huge_Job value in the <i>egapx/ui/assets/config/process_resources.config</i> file
- The pipeline can take a lot of memory and time, if there is a large number of reads being retrieved from the SRA
- There is a limit to the number of SRA IDs that can be input to EGAPx

##### HPC scripts
The <i>egapx/ui/assets/config/process_resources.config</i> file specifies up to 31 cores (huge_Job).

##### inputData

###### reads
The read files need to be formatted very specifically, see the format_SRA_reads_EGAPx.sh and download_SRA_reads_EGAPx.sh scripts in the Formatting directory. This is because EGAPx expects that input "reads" are a list of FASTA read files, expects pairs in form SRAxxx.1, SRAxxx.2 (see the egapx/nf/./subworkflows/ncbi/./rnaseq_short/star_wnode/main.nf file).

###### reads_ids
There is a limit to the number of SRA IDs that can be input to EGAPx, since the pipeline makes a query to the SRA. The HTTP header becomes too large if the list of SRA IDs is very long. 

###### NCBI Data Sets
These IDs were retrieved from the annotation report pages of each species. For example, [KAP4 NCBI annotation report](https://www.ncbi.nlm.nih.gov/refseq/annotation_euk/Daphnia_pulex/100/). These are the "RNA-Seq alignments" "Project" IDs and the "SRA Long Read Alignment Statistics" "Run" ID. The unique Project IDs are being used since EGAPx fails if the HTTP header becomes to large from a long list of samples.

##### EGAPx Config
ND CRC [system specifications](https://docs.crc.nd.edu/new_user/quick_start.html).

The following template may be used to run EGAPx workflow jobs on the ND CRC remote servers. The config file template can also be found in the <i>EGAPx_v0.2_process_resources.config</i> file in the <i>inputData</i> directory.

###### Template
// Part of nextflow config describing resource requirements for EGAPx processes

// We rely on labels to define 3 tiers of processes - default, big, and huge.

// Make sure that executor you use supports job memory and CPU requirements

process {

    memory = 200.GB
    cpus = 63
    time = 336.h

    withLabel: 'big_job' {
        memory = 200.GB
        cpus = 63
    }

    withLabel: 'huge_job' {
        memory = 200.GB
        cpus = 63
    }

    withLabel: 'long_job' {
        time = 336.h
    }
}

# DaphniaTranscriptomics_PfrenderLab

This is a repository with code for analyzing Daphnia omics data.

## Genome Annotation - [EGAPx](https://github.com/ncbi/egapx/) Workflows
The workflow for EGAPx is setup for job submission to the ND CRC remote servers.

Note that singularity needs to be installed on your system. The ND CRC servers already have singularity available.

### Steps
1. Install and test the EGAPx software.
2. Format any input files, such as the reads fasta files or yaml guide file.
3. Run EGAPx using as many cores as possible and with sufficient data storage. This will depend on the size and number of input files, for example.

### Installation
The <i>install_EGAPx.sh</i> script in the <b>install</b> directory can be used to install EGAPx and its dependencies. 

Make sure to change the paths in the <i>inputs_annotations.txt</i> file to where you would like to have the software installed and outputs generated.

### Notes
There are some things to keep in mind when running EGAPx.

#### EGAPx Config
The <i>egapx/ui/assets/config/process_resources.config</i> file specifies up to 31 cores (huge_Job).

The ND CRC [system specifications](https://docs.crc.nd.edu/new_user/quick_start.html) indicates that our afs system has 263Gb RAM, 64 cores. Make sure to leave 1 core free for general processes, so request up to 63 cores per job on our afs system.

The <i>EGAPx_v0.2_process_resources.config</i> file in the <i>inputData</i> directory may be used to run EGAPx workflow jobs on the ND CRC remote servers.

It is also possible to set the config using the -c or --config-dir CONFIG_DIR flag (see the GitHub README for EGAPx or run <i>ui/egapx.py  -h</i>).

#### inputData

##### reads

###### EGAPx v0.1
The read fasta files need to be formatted very specifically, see the <i>format_trimmed_reads_EGAPx.sh</i> script in the <b>formatting</b> directory.

EGAPx v0.1 expects the headers to simple, such as single words (e.g., read ID or name) with no extra spaces or strange symbols. Additionally, the fasta file needs to contain just header and sequence information (no quality scores, etc.).

EGAPx v0.1 expects that input reads are a list of FASTA read files, which are named in the form SRAxxx.1, SRAxxx.2 (see the <i>egapx/nf/./subworkflows/ncbi/./rnaseq_short/star_wnode/main.nf</i> file).

###### EGAPx v0.2
EGAPx v0.2 expects the headers to simple, such as single words (e.g., read ID or name) with no extra spaces or strange symbols.

<b>TO-DO:</b> Altert EGAPx creators of the following error.
EGAPx v0.2 should be able to accept fasta files compressed into gz format. However, the following error is returned on our ND CRC remote server system (see https://www.biostars.org/p/9469010/):
Exiting because of \*FATAL ERROR\*: could not create FIFO file wrkarea/STAR.65804014732736FFdFHY/D.pulicaria_LARRY_HIC_final-18CRep1_ATCACG_L001_R1.concat.fq/D.pulicaria_LARRY_HIC_final-18CRep1_ATCACG_L001_R1.concat.fq-\_STARtmp/tmp.fifo.read1

##### reads_ids

###### EGAPx v0.1 & EGAPx v0.2
There is a limit to the number of SRA IDs that can be input to EGAPx, since the pipeline makes a query to the SRA. The HTTP header becomes too large if the list of SRA IDs is very long. 

###### NCBI Data Sets
These IDs can be retrieved from the annotation report pages of each species. For example, [KAP4 NCBI annotation report](https://www.ncbi.nlm.nih.gov/refseq/annotation_euk/Daphnia_pulex/100/). These are the "RNA-Seq alignments" "Project" IDs and the "SRA Long Read Alignment Statistics" "Run" ID. The unique Project IDs are being used since EGAPx fails if the HTTP header becomes to large from a long list of samples.

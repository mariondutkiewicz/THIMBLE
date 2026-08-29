#!/bin/bash
# Authors: Nicolas Godron, Marion Dutkiewicz
# Master script for metagenomics analysis

###### REQUIRED ##################
# Samples file (all sample names, variable $SAMPLES_LIST)
# Absolute paths to FASTQ files (written to file in variable $FASTQ_PATHS)
# Check directory paths and main parameters.

###### MAIN DIRECTORY PATHS ######
WORK_DIR="/home/mdutkiewicz/work/"
SAVE_DIR="/home/mdutkiewicz/save/"

MAIN_DIR="${WORK_DIR}/2026_Sewage_surveillance/"

INTERMEDIATE_DIR_META="${MAIN_DIR}/intermediate_meta/"
OUTPUT_DIR_META="${MAIN_DIR}/output_meta/"

###### MAIN PARAMETERS ###########
THREADS=64
R1_SUFFIX="R1_001"
R2_SUFFIX="R2_001"
FASTQ_SUFFIX=".fastq.gz"
FASTA_EXTENSION=".fasta"

###### ABSOLUTE PATHS ###########
# Absolute path to a text file with one sample name per line (without the "fastq.gz" extension)
SAMPLES_LIST="${MAIN_DIR}meta_run_1_samples.IDs"

# File with absolute paths of raw reads file, one fastq file per line.
FASTQ_PATHS="${MAIN_DIR}fastq_paths_meta_run_1.txt"

mkdir -p $INTERMEDIATE_DIR_META $OUTPUT_DIR_META

# ~~~ STEP 1: FastQC (pre-trimming) ~~~
FASTQC_ENV="fastqc-0.12.1"
PRETRIM_FASTQC_OUTDIR="${OUTPUT_DIR_META}1-fastqc_pretrim/"
PRETRIM_FASTQC_COMMAND="conda activate $FASTQC_ENV && $MAIN_DIR/scripts_meta/1-fastqc_pre.sh $FASTQ_PATHS $PRETRIM_FASTQC_OUTDIR $THREADS && conda deactivate"

mkdir -p $PRETRIM_FASTQC_OUTDIR

qsub -cwd -V -N MD_fastQC_pretrim_meta \
	-q short.q \
	-pe thread $THREADS \
	-m ea \
	-M marion.dutkiewicz@aphp.fr,nicolas.godron@inserm.fr \
	-b y \
	$PRETRIM_FASTQC_COMMAND

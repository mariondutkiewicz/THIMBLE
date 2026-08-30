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

# ~~~ STEP 2: Trimmomatic ~~~
TRIM_ENV="trimmomatic-0.39"
TRIM_OUTDIR="${OUTPUT_DIR_META}2-trimmomatic/"
TRIM_INTER="${INTERMEDIATE_DIR_META}trimming_intermediate/"
TRIM_COMMAND="conda activate $TRIM_ENV && $MAIN_DIR/scripts_meta/2-trimmomatic.sh \
	$FASTQ_PATHS $TRIM_OUTDIR $TRIM_INTER $THREADS $R1_SUFFIX $R2_SUFFIX $FASTQ_SUFFIX && conda deactivate"

mkdir $TRIM_OUTDIR $TRIM_INTER

qsub -cwd -V -N MD_trimmomatic_meta \
	-q short.q \
	-pe thread $THREADS \
	-m ea \
	-M marion.dutkiewicz@aphp.fr,nicolas.godron@inserm.fr \
	-b y \
	$TRIM_COMMAND

# ~~~ STEP 2.1: FastQC (post-trimming) ~~~
TRIM_OUTDIR="${OUTPUT_DIR_META}2-trimmomatic/"

FASTQC_ENV="fastqc-0.12.1"
POSTTRIM_FASTQC_OUTDIR="${OUTPUT_DIR_META}2.1-fastqc_posttrim/"
POSTTRIM_FASTQC_COMMAND="conda activate $FASTQC_ENV && $MAIN_DIR/scripts_meta/2.1-fastqc_post.sh $TRIM_OUTDIR $POSTTRIM_FASTQC_OUTDIR $SAMPLES_LIST $THREADS && conda deactivate"

mkdir -p $POSTTRIM_FASTQC_OUTDIR

qsub -cwd -V -N MD_fastQC_posttrim_meta \
	-q short.q \
	-pe thread $THREADS \
	-m ea \
	-M marion.dutkiewicz@aphp.fr,nicolas.godron@inserm.fr \
	-b y \
	$POSTTRIM_FASTQC_COMMAND


# ~~~ STEP 3: Kraken2 ~~~
TRIM_OUTDIR="${OUTPUT_DIR_META}2-trimmomatic/"

KRAKEN_ENV="kraken2-2.17.1"
KRAKEN_OUTDIR="${OUTPUT_DIR_META}3-kraken/"
KRAKEN_COMMAND="conda activate $KRAKEN_ENV && $MAIN_DIR/scripts_meta/3-kraken2.sh $TRIM_OUTDIR $KRAKEN_OUTDIR $SAMPLES_LIST $THREADS && conda deactivate"

mkdir -p $KRAKEN_OUTDIR

qsub -cwd -V -N MD_kraken2 \
	-q short.q \
	-pe thread $THREADS \
	-m ea \
	-M marion.dutkiewicz@aphp.fr,nicolas.godron@inserm.fr \
	-b y \
	$KRAKEN_COMMAND

# ~~~ STEP 3.1: Bracken ~~~
KRAKEN_OUTDIR="${OUTPUT_DIR_META}3-kraken/"

BRACKEN_ENV="bracken-3.1"
BRACKEN_OUTDIR="${OUTPUT_DIR_META}3.1-bracken/"
BRACKEN_COMMAND="conda activate $BRACKEN_ENV && $MAIN_DIR/scripts_meta/3.1-bracken.sh $KRAKEN_OUTDIR $BRACKEN_OUTDIR $SAMPLES_LIST && conda deactivate"

mkdir -p $BRACKEN_OUTDIR

qsub -cwd -V -N MD_bracken \
	-q short.q \
	-pe thread $THREADS \
	-m ea \
	-M marion.dutkiewicz@aphp.fr,nicolas.godron@inserm.fr \
	-b y \
	$BRACKEN_COMMAND

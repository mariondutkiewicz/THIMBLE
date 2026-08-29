#!/bin/bash

# Script: 2-trimmomatic.sh
# Usage: ./2-trimmomatic.sh <fastq_paths_file> <output_dir> <intermediate_dir> <threads>

set -e

FASTQ_PATHS="$1"
TRIM_OUTDIR="$2"
TRIM_INTER="$3"
THREADS="$4"
R1_SUFFIX="$5"
R2_SUFFIX="$6"
FASTQ_SUFFIX="$7"

THREADS_PER_JOB=4
NUM_PARALLEL=$((THREADS / THREADS_PER_JOB))

# Validate inputs
if [[ ! -f "$FASTQ_PATHS" ]]; then
    echo "Error: Input file '$FASTQ_PATHS' not found"
    exit 1
fi

mkdir -p "$TRIM_OUTDIR" "$TRIM_INTER"

echo "Starting Trimmomatic parallel processing"
echo "Total threads: $THREADS"
echo "Threads per job: $THREADS_PER_JOB"
echo "Parallel jobs: $NUM_PARALLEL"
echo ""

# Read R1 files and parallelize
grep "${R1_SUFFIX}${FASTQ_SUFFIX}" "$FASTQ_PATHS" | xargs -P $NUM_PARALLEL -I {} bash -c '
  R1="{}"
  R2="$(echo $R1 | sed 's/${R1_SUFFIX}${FASTQ_SUFFIX}/${R2_SUFFIX}${FASTQ_SUFFIX}/g' )"
  
  # Validate files - To do: make this warning go up into main bash STDERR
  if [[ ! -f "$R1" ]]; then
    echo "Error: R1 file not found: $R1"
    exit 1
  fi
  
  if [[ ! -f "$R2" ]]; then
    echo "Error: R2 file not found: $R2"
    exit 1
  fi
  
  BASENAME=$(basename "$R1" "${R1_SUFFIX}${FASTQ_SUFFIX}")
  TRIM_OUTDIR="'"$TRIM_OUTDIR"'"
  TRIM_INTER="'"$TRIM_INTER"'"
  THREADS_PER_JOB="'"$THREADS_PER_JOB"'"
  
  # Output files
  OUT_R1P="${TRIM_OUTDIR}${BASENAME}_1.trimmed.fq.gz"
  OUT_R1U="${TRIM_INTER}${BASENAME}_1.unpaired.fq.gz"
  OUT_R2P="${TRIM_OUTDIR}${BASENAME}_2.trimmed.fq.gz"
  OUT_R2U="${TRIM_INTER}${BASENAME}_2.unpaired.fq.gz"
  TRIM_LOG=$(mktemp)
  
  # Run trimmomatic
  trimmomatic PE -threads $THREADS_PER_JOB -phred33 \
    "$R1" "$R2" \
    "$OUT_R1P" "$OUT_R1U" \
    "$OUT_R2P" "$OUT_R2U" \
    ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
    LEADING:20 TRAILING:20 SLIDINGWINDOW:4:15 MINLEN:51
  
echo "Trimmomatic processing completed"
'

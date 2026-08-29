#!/bin/bash

# Script: 1-fastqc_pre.sh
# Usage: ./1-fastqc_pre.sh <fastq> <output_dir> <threads>

set -e

FASTQ_PATHS="$1"
PRETRIM_FASTQC_OUTDIR="$2"
THREADS="$3"

THREADS_PER_JOB=8
NUM_PARALLEL=$((THREADS / THREADS_PER_JOB))

# Validate input
if [[ ! -e "$FASTQ_PATHS" ]]; then
    echo "Error: Input '$FASTQ_PATHS' not found"
    exit 1
fi

mkdir -p "$PRETRIM_FASTQC_OUTDIR"

echo "Starting FastQC analysis"
echo "Total threads: $THREADS"
echo "Threads per job: $THREADS_PER_JOB"
echo "Parallel jobs: $NUM_PARALLEL"
echo ""

# Process samples in parallel with xargs
grep -v "^#\|^$" "$FASTQ_PATHS" | xargs -P $NUM_PARALLEL -I {} bash -c '
  FASTQ_PATHS="{}"
  PRETRIM_FASTQC_OUTDIR="'"$PRETRIM_FASTQC_OUTDIR"'"
  THREADS_PER_JOB="'"$THREADS_PER_JOB"'"
  
  fastqc \
  --outdir "$PRETRIM_FASTQC_OUTDIR" \
  --noextract \
  --threads "$THREADS_PER_JOB" \
  "$FASTQ_PATHS"
  
echo "FastQC analysis completed"
'

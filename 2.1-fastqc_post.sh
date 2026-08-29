#!/bin/bash

# Script: 2.1-fastqc_post.sh
# Usage: ./2.1-fastqc_post.sh <fastq_trimmed> <output_dir> <threads>

set -e

TRIM_OUTDIR="$1"
POSTTRIM_FASTQC_OUTDIR="$2"
THREADS="$3"

THREADS_PER_JOB=8
NUM_PARALLEL=$((THREADS / THREADS_PER_JOB))

# Validate input
if [[ ! -e "$TRIM_OUTDIR" ]]; then
    echo "Error: Input '$TRIM_OUTDIR' not found"
    exit 1
fi

mkdir -p "$POSTTRIM_FASTQC_OUTDIR"

echo "Starting FastQC analysis"
echo "Total threads: $THREADS"
echo "Threads per job: $THREADS_PER_JOB"
echo "Parallel jobs: $NUM_PARALLEL"
echo ""

# Process samples in parallel with xargs
grep -v "^#\|^$" "$TRIM_OUTDIR" | xargs -P $NUM_PARALLEL -I {} bash -c '
  TRIM_OUTDIR="{}"
  POSTTRIM_FASTQC_OUTDIR="'"$POSTTRIM_FASTQC_OUTDIR"'"
  THREADS_PER_JOB="'"$THREADS_PER_JOB"'"
  
  fastqc \
  --outdir "$POSTTRIM_FASTQC_OUTDIR" \
  --noextract \
  --threads "$THREADS_PER_JOB" \
  "$TRIM_OUTDIR"
  
echo "FastQC analysis completed"
'

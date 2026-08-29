#!/bin/bash

# Script: 1-fastqc.sh
# Usage: ./1-fastqc.sh <fastq_paths_or_dir> <output_dir> <threads>

set -e

INPUT="$1"
FASTQC_OUTDIR="$2"
THREADS="$3"

NUM_PARALLEL=$THREADS

# Validate input
if [[ ! -e "$INPUT" ]]; then
    echo "Error: Input '$INPUT' not found"
    exit 1
fi

mkdir -p "$FASTQC_OUTDIR"

echo "Starting FastQC analysis"
echo "Total threads: $THREADS"
echo "Parallel jobs: $NUM_PARALLEL"
echo ""

# Process all fastq files in parallel
echo "$FILE_LIST" | xargs -P $NUM_PARALLEL -I {} bash -c '
  FASTQ_FILE="{}"
  FASTQC_OUTDIR="'"$FASTQC_OUTDIR"'"
  SHARED_LOG="'"$SHARED_LOG"'"
  LOCK_FILE="'"$LOCK_FILE"'"
  
  # Validate file
  if [[ ! -f "$FASTQ_FILE" ]]; then
    echo "Error: FASTQ file not found: $FASTQ_FILE"
    exit 1
  fi
  
  BASENAME=$(basename "$FASTQ_FILE" | sed "s/\\.fq\\.gz\|\\.fastq\\.gz\|\\.fq\|\\.fastq|\\.trimmed\\.fq\\.gz//")
  
  fastqc -o "$FASTQC_OUTDIR" --noextract "$FASTQ_FILE" 2>&1
  
echo "FastQC analysis completed for $BASENAME"
'

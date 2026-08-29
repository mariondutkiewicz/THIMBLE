#!/bin/bash

# Script: 3-kraken2.sh
# Usage: ./3-kraken2.sh <fastq> <output_dir> <threads>

set -e

TRIM_OUTDIR="$1"
KRAKEN_OUTDIR="$2"
SAMPLES_LIST="$3"
THREADS="$4"

THREADS_PER_JOB=64
NUM_PARALLEL=1

mkdir -p "$KRAKEN_OUTDIR"

# Validate inputs
if [ ! -s "$TRIM_OUTDIR" ]; then
    echo "Error: Input file '${TRIM_OUTDIR}' does not exist."
    exit 1
fi

echo "Starting kraken2 processing"
echo "Total threads: $THREADS"
echo "Threads per job: $THREADS_PER_JOB"
echo "Parallel jobs: $NUM_PARALLEL"
echo ""

grep -v "^#\|^$" "$SAMPLES_LIST" | xargs -P "$NUM_PARALLEL" -I {} bash -c '
  SAMPLE_ID="{}"
  TRIM_OUTDIR="'"$TRIM_OUTDIR"'"
  KRAKEN_OUTDIR="'"$KRAKEN_OUTDIR"'"
  THREADS_PER_JOB="'"$THREADS_PER_JOB"'"

  mapfile -t R1_FILES < <(find "$TRIM_OUTDIR" -maxdepth 1 -name "${SAMPLE_ID}_S*_L*_R1_001.fastq.gz_1.trimmed.fq.gz" | sort)
  mapfile -t R2_FILES < <(find "$TRIM_OUTDIR" -maxdepth 1 -name "${SAMPLE_ID}_S*_L*_R1_001.fastq.gz_2.trimmed.fq.gz" | sort)

  kraken2 \
    --db /db/outils/kraken2-2026/k2_standard_20260226 \
    --threads "$THREADS_PER_JOB" \
    --paired \
    --output "$KRAKEN_OUTDIR/${SAMPLE_ID}.kraken" \
    --report "$KRAKEN_OUTDIR/${SAMPLE_ID}.report" \
    <(zcat "${R1_FILES[@]}") <(zcat "${R2_FILES[@]}")

echo "kraken2 processing completed for $SAMPLE_ID"
'

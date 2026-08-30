#!/bin/bash

# Script: 3.1-bracken.sh
# Usage: ./3.1-bracken.sh <kraken_reports> <output_dir> <threads>

set -e

KRAKEN_OUTDIR="$1"
BRACKEN_OUTDIR="$2"
SAMPLES_LIST="$3"

NUM_PARALLEL=1

mkdir -p "$BRACKEN_OUTDIR"

# Validate inputs
if [ ! -s "$KRAKEN_OUTDIR" ]; then
    echo "Error: Input file '${KRAKEN_OUTDIR}' does not exist."
    exit 1
fi

echo "Starting bracken processing"
echo "Parallel jobs: $NUM_PARALLEL"
echo ""

grep -v "^#\|^$" "$SAMPLES_LIST" | xargs -P "$NUM_PARALLEL" -I {} bash -c '
  SAMPLE_ID="{}"
  KRAKEN_OUTDIR="'"$KRAKEN_OUTDIR"'"
  BRACKEN_OUTDIR="'"$BRACKEN_OUTDIR"'"

    bracken \
      MY_DB /db/outils/kraken2-2026/k2_standard_20260226 \
      INPUT "$KRAKEN_OUTDIR/${SAMPLE_ID}.report" \
      OUTPUT "$BRACKEN_OUTDIR/${SAMPLE_ID}_bracken_species.txt" \
      OUTREPORT "$BRACKEN_OUTDIR/${SAMPLE_ID}_bracken.report" \
      READ_LEN 150 \
      LEVEL S \
      THRESHOLD 0 

echo "bracken processing completed for $SAMPLE_ID"
'

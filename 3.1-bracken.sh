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
      -d /db/outils/kraken2-2026/k2_standard_20260226 \
      -i "$KRAKEN_OUTDIR/${SAMPLE_ID}.report" \
      -o "$BRACKEN_OUTDIR/${SAMPLE_ID}_bracken_genus.txt" \
      -r 150 \
      -l G \
      -t 10 

echo "bracken processing completed for $SAMPLE_ID"
'

# Au moment du premier lancement de Bracken, pour que ce soit plus propre -w "$BRACKEN_OUTDIR/${SAMPLE_ID}_bracken.report" \

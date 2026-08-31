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
      -o "$BRACKEN_OUTDIR/${SAMPLE_ID}_bracken_families.txt" \
      -r 150 \
      -l F \
      -t 10 

echo "bracken processing completed for $SAMPLE_ID"
'

# Au moment du premier lancement de Bracken, pour que ce soit plus propre -w "$BRACKEN_OUTDIR/${SAMPLE_ID}_bracken.report" \

# Lignes pour concaténer les sorties de bracken
# BRACKEN_OUTDIR="3.1-bracken"
# OUTPUT_TSV="all_samples_bracken_families.tsv"

# echo -e "sample\tname\ttaxonomy_id\ttaxonomy_lvl\tkraken_assigned_reads\tadded_reads\tnew_est_reads\tfraction_total_reads" > "$OUTPUT_TSV"

# for f in "$BRACKEN_OUTDIR"/*_bracken_families.txt; do
   # SAMPLE=$(basename "$f" _bracken_families.txt)
   # tail -n +2 "$f" | awk -F'\t' -v sample="$SAMPLE" 'BEGIN{OFS="\t"} {print sample, $0}' >> "$OUTPUT_TSV"
#done

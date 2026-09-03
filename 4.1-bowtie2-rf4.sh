#!/bin/bash

# Script: 4.1-bowtie2-rf4.sh
# Usage: ./4.1-bowtie2-rf4.sh <fastq> <output_dir> <threads>

set -e

TRIM_OUTDIR="$1"
BOWTIE_OUTDIR="$2"
SAMPLES_LIST="$3"
THREADS="$4"

THREADS_PER_JOB=64
NUM_PARALLEL=1

mkdir -p "$BOWTIE_OUTDIR"

# Validate inputs
if [ ! -s "$TRIM_OUTDIR" ]; then
    echo "Error: Input file '${TRIM_OUTDIR}' does not exist."
    exit 1
fi

echo "Starting bowtie2 processing"
echo "Total threads: $THREADS"
echo "Threads per job: $THREADS_PER_JOB"
echo "Parallel jobs: $NUM_PARALLEL"
echo ""

grep -v "^#\|^$" "$SAMPLES_LIST" | xargs -P "$NUM_PARALLEL" -I {} bash -c '
  SAMPLE_ID="{}"
  TRIM_OUTDIR="'"$TRIM_OUTDIR"'"
  BOWTIE_OUTDIR="'"$BOWTIE_OUTDIR"'"
  THREADS_PER_JOB="'"$THREADS_PER_JOB"'"

  BOWTIE2_INDEX_RF4="/work_home/mdutkiewicz/2026_Sewage_surveillance/db_resfinder4/resfinder4"

  mapfile -t R1_FILES < <(find "$TRIM_OUTDIR" -maxdepth 1 -name "${SAMPLE_ID}_S*_L*_R1_001.fastq.gz_1.trimmed.fq.gz" | sort)
  mapfile -t R2_FILES < <(find "$TRIM_OUTDIR" -maxdepth 1 -name "${SAMPLE_ID}_S*_L*_R1_001.fastq.gz_2.trimmed.fq.gz" | sort)

  bowtie2 \
    -x "$BOWTIE2_INDEX_RF4" \
    -1 <(zcat "${R1_FILES[@]}") \
    -2 <(zcat "${R2_FILES[@]}") \
    -p "$THREADS_PER_JOB" \
    --sensitive-local \
    --no-unal \
    | samtools sort -@ "$THREADS_PER_JOB" -o "$BOWTIE_OUTDIR/${SAMPLE_ID}_resfinder4.sorted.bam" -
    
  samtools index "$BOWTIE_OUTDIR/${SAMPLE_ID}_resfinder4.sorted.bam"
  echo "bowtie2 processing completed for $SAMPLE_ID"
'

# à la fin, pour agréger les résultats
BOWTIE_OUTDIR="4.1-bowtie-rf4"
OUTPUT_TSV="all_samples_ARG_counts_resfinder4.tsv"

echo -e "sample\tgene\tgene_length\tmapped_reads" > "$OUTPUT_TSV"

for bam in ./*_resfinder4.sorted.bam; do
    SAMPLE=$(basename "$bam" _resfinder4.sorted.bam)
    samtools idxstats "$bam" | awk -F'\t' -v sample="$SAMPLE" 'BEGIN{OFS="\t"} $1 != "*" && $3 > 0 {print sample, $1, $2, $3}' >> "$OUTPUT_TSV"
done

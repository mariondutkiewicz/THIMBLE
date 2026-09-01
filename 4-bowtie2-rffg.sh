#!/bin/bash

# Script: 4-bowtie2-rffg.sh
# Usage: ./4-bowtie2-rffg.sh <fastq> <output_dir> <threads>

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

  BOWTIE2_INDEX="/work_home/mdutkiewicz/2026_Sewage_surveillance/db_resfinderfg/bowtie2_index/ResFinder_FG"

  mapfile -t R1_FILES < <(find "$TRIM_OUTDIR" -maxdepth 1 -name "${SAMPLE_ID}_S*_L*_R1_001.fastq.gz_1.trimmed.fq.gz" | sort)
  mapfile -t R2_FILES < <(find "$TRIM_OUTDIR" -maxdepth 1 -name "${SAMPLE_ID}_S*_L*_R1_001.fastq.gz_2.trimmed.fq.gz" | sort)

  bowtie2 \
    -x "$BOWTIE2_INDEX" \
    -1 <(zcat "${R1_FILES[@]}") \
    -2 <(zcat "${R2_FILES[@]}") \
    -p "$THREADS_PER_JOB" \
    --sensitive-local \
    | samtools sort -@ "$THREADS_PER_JOB" -o "$BOWTIE_OUTDIR/${SAMPLE_ID}.sorted.bam" -
    
  samtools index "$BOWTIE_OUTDIR/${SAMPLE_ID}.sorted.bam"
  echo "bowtie2 processing completed for $SAMPLE_ID"
'

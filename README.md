# THIMBLE

Throughput Holistic Inference from Metagenomic Biomarkers in Liquid Environments

Genomics pipeline for shotgun metagenomics ouput ; wastewater based

```mermaid
flowchart TD
    Raw_reads -- "Quality control before trimming" --> FastQC+MultiQC
    Raw_reads --> Trimmomatic

    Trimmomatic -- "Quality control after trimming" --> FastQC+MultiQC
    Trimmomatic -- "Trimmed reads" --> Kraken2

    Kraken2 -- "Kraken_reports" --> Bracken
    
```

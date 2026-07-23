# ChIPflow

![Language](https://img.shields.io/badge/Language-Nextflow-41ab5d?style=flat-square)
![DSL](https://img.shields.io/badge/DSL-DSL2-brightgreen?style=flat-square)
![Containers](https://img.shields.io/badge/Containers-Singularity-blue?style=flat-square)
![Genome](https://img.shields.io/badge/Genome-hg38%20%7C%20mm10-lightgrey?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

## ChIP-seq Analysis Pipeline

A modular, end-to-end ChIP-seq analysis pipeline built with **Nextflow DSL2**. Designed for processing paired-end or single-end ChIP-seq data from raw FASTQ files through quality control, alignment, peak calling, annotation, and motif enrichment, culminating in a comprehensive MultiQC report.

---

## Table of Contents

- [Overview](#overview)
- [Pipeline Workflow](#pipeline-workflow)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Samplesheet Format](#samplesheet-format)
- [Parameters](#parameters)
- [Output Structure](#output-structure)
- [Software & Containers](#software--containers)
- [Reference Genome Setup](#reference-genome-setup)
- [Related Projects](#related-projects)
- [Author](#author)

---

## Overview

This pipeline automates the complete ChIP-seq analysis workflow including:

- Raw read quality control and adapter trimming
- Choice of STAR or Bowtie2 alignment
- Duplicate marking and removal (Picard + Samtools)
- ENCODE blacklist filtering
- Signal track generation (bedGraph → bigWig)
- Peak calling with MACS2 (narrow or broad peaks; paired-end BAMPE mode supported)
- Peak annotation with HOMER annotatePeaks
- Motif enrichment analysis with HOMER findMotifsGenome
- Fingerprint plot (deepTools plotFingerprint)
- Aggregated MultiQC report with custom QC sections

Supports both **paired-end (PE)** and **single-end (SE)** libraries, and multiple ChIP targets with a matched input control per condition, containerised with Singularity for full reproducibility.

---

## Pipeline Workflow

```
FASTQ (PE or SE)
    │
    ├──► FastQC            → raw read QC
    │
    ├──► FASTP             → adapter trimming + QC
    │
    ├──► STAR / Bowtie2   → genome alignment (SAM)
    │
    ├──► Samtools          → sort + index (BAM)
    │
    ├──► Picard            → mark duplicates
    │
    ├──► Samtools          → remove duplicates
    │
    ├──► Bedtools          → ENCODE blacklist filter
    │
    ├──► Samtools          → sort + index (filtered BAM)
    │
    ├──► Bedtools          → bedGraph generation
    ├──► UCSC              → bigWig conversion
    │
    ├──► deepTools         → plotFingerprint (all samples)
    │
    ├──► MACS2             → peak calling (narrowPeak / broadPeak)
    │
    ├──► HOMER             → annotatePeaks (peak annotation + stats)
    ├──► HOMER             → findMotifsGenome (known motif enrichment)
    │
    └──► MultiQC           → aggregated QC report
```

---

## Requirements

- [Nextflow](https://www.nextflow.io/) ≥ 20.07.1
- [Singularity](https://sylabs.io/singularity/) (containers are pre-configured; Docker URIs also included as comments in the config)
- Reference genome FASTA, GTF, aligner index, chromosome sizes, and ENCODE blacklist BED file

---

## Installation

```bash
git clone https://github.com/a-sundaresan/ChIPflow.git
cd ChIPflow
```

No package installation is needed — all tools run inside Singularity containers defined in `nextflow.config`.

---

## Usage

```bash
# Run with STAR aligner (default)
nextflow run main.nf --aligner star --csv samplesheet.csv

# Run with Bowtie2
nextflow run main.nf --aligner bowtie2 --csv samplesheet.csv

# Resume a failed/interrupted run
nextflow run main.nf --aligner star --csv samplesheet.csv -resume
```

---

## Samplesheet Format

The samplesheet is a comma-separated CSV file with the following columns:

| Column | Description |
|--------|-------------|
| `sample` | Sample name (used for output file naming) |
| `replicate` | Replicate label, e.g. `REP1`, `REP2` |
| `fastq_1` | Path to R1 FASTQ file (`.fastq.gz` or `.fq.gz`) |
| `fastq_2` | Path to R2 FASTQ file — leave blank for single-end |
| `antibody` | Antibody/mark name (e.g. `H3K27ac`); **leave blank for input control rows** |
| `control` | Name of the matched input control sample; leave blank for input rows |

### Example — Paired-End with two replicates

```
sample,replicate,fastq_1,fastq_2,antibody,control
H3K27ac_WT,REP1,H3K27ac_WT_R1_1.fastq.gz,H3K27ac_WT_R1_2.fastq.gz,H3K27ac,Input_WT
H3K27ac_WT,REP2,H3K27ac_WT_R2_1.fastq.gz,H3K27ac_WT_R2_2.fastq.gz,H3K27ac,Input_WT
Input_WT,REP1,Input_WT_R1_1.fastq.gz,Input_WT_R1_2.fastq.gz,,
Input_WT,REP2,Input_WT_R2_1.fastq.gz,Input_WT_R2_2.fastq.gz,,
```

### Example — Single-End with one replicate per condition

```
sample,replicate,fastq_1,fastq_2,antibody,control
H3K27ac_Th17,REP1,SRR12601611_1.fastq.gz,,H3K27ac,Input_Th17
H3K27ac_Th17,REP2,SRR12601613_1.fastq.gz,,H3K27ac,Input_Th17
Input_Th17,REP1,SRR12601612_1.fastq.gz,,,
Input_Th17,REP2,SRR12601614_1.fastq.gz,,,
```

**Important:**
- Input control rows must have the `antibody` column **empty** so the pipeline can distinguish them from ChIP samples.
- Multiple ChIP replicates pointing to the same control sample name will have all matching input BAMs pooled for peak calling.

---

## Parameters

All parameters are set in `nextflow.config` under the `params` block, or passed directly on the command line with `--param value`.

| Parameter | Default | Description |
|-----------|---------|-------------|
| `csv` | `samplesheet.csv` | Path to the samplesheet CSV |
| `outdir` | `results` | Output directory |
| `aligner` | `star` | Aligner to use: `star` or `bowtie2` |
| `STAR_genomeDir` | — | Path to STAR genome index directory |
| `bowtie2_index` | — | Path to Bowtie2 index prefix |
| `fasta` | — | Path to reference genome FASTA |
| `gtf` | — | Path to GTF annotation file |
| `encode_blacklist` | — | Path to ENCODE blacklist BED file |
| `chrom_size` | — | Path to chromosome sizes file |
| `macs2_genome_size` | `hs` | MACS2 effective genome size: `hs` (human) or `mm` (mouse) |
| `fail_on_missing` | `true` | Fail if input FASTQ files are missing; set to `false` to skip |

---

## Output Structure

```
results/
├── fastqc/                         # Raw FastQC reports
├── fastp/                          # Trimmed reads + fastp reports
├── alignment/
│   ├── STAR/                       # Sorted, indexed BAMs (STAR)
│   └── BOWTIE2/                    # Sorted, indexed BAMs (Bowtie2)
├── duplicates/
│   ├── markdup/                    # Duplicate-marked BAMs + Picard metrics
│   └── dedup/                      # Deduplicated BAMs + flagstats
├── filter_encode/                  # Blacklist-filtered BAMs + QC stats
├── bigwigs/
│   ├── bedgraph/                   # bedGraph signal tracks
│   └── bigwig/                     # bigWig signal tracks
├── plotfingerprint/                # deepTools fingerprint plot + metrics
├── peak_calling/
│   ├── peaks/                      # MACS2 peak files (narrowPeak/broadPeak, XLS)
│   └── qc/                         # MACS2 peak count QC table
├── peak_annotate/
│   ├── peak_annotation/            # HOMER annotation files + stats
│   └── qc/                         # HOMER annotation QC table
├── peak_motif/                     # HOMER motif enrichment results
└── multiqc/                        # Aggregated MultiQC HTML report
```

---

## Software & Containers

All tools run inside Singularity containers. Docker image URIs are also provided as comments in `nextflow.config` for Docker-based environments.

| Tool | Version | Purpose |
|------|---------|---------|
| FastQC | 0.12.1 | Raw read quality control |
| fastp | 0.24.0 | Adapter trimming and QC |
| STAR | 2.7.10b | Splice-aware alignment |
| Bowtie2 | 2.5.2 | Fast short-read alignment |
| Samtools | 1.21 | BAM sorting, indexing, flagstat |
| Picard | 3.3.0 | Duplicate marking |
| Bedtools | 2.31.1 | Blacklist filtering, bedGraph generation |
| UCSC bedGraphToBigWig | 469 | Signal track conversion |
| deepTools | 3.5.1 | Fingerprint plot |
| MACS2 | 2.2.7.1 | Peak calling |
| HOMER | 4.11 | Peak annotation and motif enrichment |
| MultiQC | 1.21 | Aggregated QC report |

---

## Reference Genome Setup

### Human (GRCh38 / hg38)

ENCODE provides a standardized analysis-ready reference:

```bash
# Genome FASTA
wget https://www.encodeproject.org/files/GRCh38_no_alt_analysis_set_GCA_000001405.15/@@download/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta.gz

# GTF (GENCODE v29)
wget https://www.encodeproject.org/files/ENCFF598IDH/@@download/ENCFF598IDH.gtf.gz

# Blacklist
wget https://raw.githubusercontent.com/Boyle-Lab/Blacklist/master/lists/hg38-blacklist.v2.bed.gz
```

### Mouse (GRCm38 / mm10)

```bash
# Genome FASTA
wget https://www.encodeproject.org/files/mm10_no_alt_analysis_set_ENCODE/@@download/mm10_no_alt_analysis_set_ENCODE.fasta.gz

# GTF (GENCODE M21)
wget https://www.encodeproject.org/files/ENCFF871VGR/@@download/ENCFF871VGR.gtf.gz

# Blacklist
wget https://raw.githubusercontent.com/Boyle-Lab/Blacklist/master/lists/mm10-blacklist.v2.bed.gz
```

### Build STAR Index

```bash
STAR --runMode genomeGenerate \
     --genomeDir /path/to/STAR_index \
     --genomeFastaFiles /path/to/genome.fasta \
     --sjdbGTFfile /path/to/annotation.gtf \
     --runThreadN 16
```

### Build Bowtie2 Index

```bash
bowtie2-build --threads 16 /path/to/genome.fasta /path/to/bowtie2_index/genome
```

### Chromosome Sizes

```bash
samtools faidx /path/to/genome.fasta
cut -f1,2 /path/to/genome.fasta.fai > chrom.sizes
```

---

## Notes

- The pipeline automatically detects PE vs SE based on whether `fastq_2` is populated in the samplesheet.
- For MACS2 peak calling, PE samples use `BAMPE` format (actual insert sizes); SE samples use `BAM` format with fragment size estimation.
- All input control replicates with the same sample name are pooled for peak calling.
- HOMER annotation uses `-annStats` to produce per-category peak counts for the MultiQC custom section.

---

## Related Projects

- [AutoAnnotSC](https://github.com/a-sundaresan/AutoAnnotSC) — Agentic scRNA-seq cell type annotation pipeline
- [RShinyApps-scAdvisorAI](https://github.com/a-sundaresan/RShinyApps-scAdvisorAI) — AI-powered scRNA-seq QC advisor
- [RShinyApps-BulkRNASeqDEAnalysis](https://github.com/a-sundaresan/RShinyApps-BulkRNASeqDEAnalysis) — Interactive bulk RNA-seq DE analysis

---

## Author

**Aishwarya Sundaresan**
[![Portfolio](https://img.shields.io/badge/Portfolio-a--sundaresan.github.io-black?style=flat-square)](https://a-sundaresan.github.io)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-aishwarya--sundaresan-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/aishwarya-sundaresan/)

#!/bin/bash
# ============================================================
# pull_containers.sh
# Downloads all Singularity containers required by the
# ChIP-seq pipeline from public Docker registries (quay.io).
#
# Usage:
#   mkdir -p containers
#   bash pull_containers.sh
#
# Images are saved to ./containers/ as .sif files.
# Update the container paths in nextflow.config to match.
# ============================================================

set -euo pipefail

OUTDIR="containers"
mkdir -p "$OUTDIR"

echo "Pulling Singularity containers into ./${OUTDIR}/"

singularity pull --name "${OUTDIR}/fastqc-0.12.1.sif" \
    docker://quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0

singularity pull --name "${OUTDIR}/fastp-0.24.0.sif" \
    docker://quay.io/biocontainers/fastp:0.24.0--heae3180_1

singularity pull --name "${OUTDIR}/star-2.7.10b.sif" \
    docker://quay.io/biocontainers/star:2.7.10b--h9ee0642_0

singularity pull --name "${OUTDIR}/bowtie2-2.5.2.sif" \
    docker://quay.io/biocontainers/bowtie2:2.5.2--py39h6fed5c7_0

singularity pull --name "${OUTDIR}/samtools-1.21.sif" \
    docker://quay.io/biocontainers/samtools:1.21--h50ea8bc_0

singularity pull --name "${OUTDIR}/picard-3.3.0.sif" \
    docker://quay.io/biocontainers/picard:3.3.0--hdfd78af_0

singularity pull --name "${OUTDIR}/bedtools-2.31.1.sif" \
    docker://quay.io/biocontainers/bedtools:2.31.1--hf5e1c6e_2

singularity pull --name "${OUTDIR}/ucsc-bedgraphtobigwig-469.sif" \
    docker://quay.io/biocontainers/ucsc-bedgraphtobigwig:469--h9b8f530_0

singularity pull --name "${OUTDIR}/deeptools-3.5.1.sif" \
    docker://quay.io/biocontainers/deeptools:3.5.1--py_0

singularity pull --name "${OUTDIR}/macs2-2.2.7.1.sif" \
    docker://quay.io/biocontainers/macs2:2.2.7.1--py38h4a8c8d9_3

singularity pull --name "${OUTDIR}/homer-4.11.sif" \
    docker://quay.io/biocontainers/homer:4.11--pl5262h4ac6f70_9

singularity pull --name "${OUTDIR}/multiqc-1.21.sif" \
    docker://quay.io/biocontainers/multiqc:1.21--pyhdfd78af_0

echo "Done. All containers saved to ./${OUTDIR}/"
echo "Update the container paths in nextflow.config to point to ./${OUTDIR}/"

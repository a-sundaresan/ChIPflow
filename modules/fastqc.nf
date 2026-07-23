process FastQC {

    tag "$sample"

    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    tuple val(sample), val(replicate), path(fastq)

    output:
    path "*.zip"
    path "*.html"

    script:
    """
    echo "Running FASTQC for sample: ${sample}_${replicate}"
    
    fastqc $fastq
    """
}

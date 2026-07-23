process SAMTOOLS_REMOVE_DUPLICATES {

    tag "$sample"

    publishDir "${params.outdir}/duplicateremoval/samtools_remove_duplicates", mode: 'copy'

    input:
    tuple val(sample), val(replicate), val(sequencing_type), path(markdup_bam)
    
    output:
    tuple val(sample),
          val(replicate),
          val(sequencing_type),
          path("*no_dups.bam"),
          path("*no_dups.bai"),
          path("*no_dups_stats.txt")

    script:
    
    """
    echo "Removing duplicates and indexing for sample: ${sample}_${replicate}"
    samtools view -F 1804 -b ${markdup_bam} > ${sample}_${replicate}.no_dups.bam
    samtools index ${sample}_${replicate}.no_dups.bam ${sample}_${replicate}.no_dups.bai
    
    # Generate mapping statistics
    samtools flagstat ${sample}_${replicate}.no_dups.bam > ${sample}_${replicate}.no_dups_stats.txt 

    """    
}

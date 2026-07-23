process SAMTOOLS_SORT_INDEX_POST_ENCODE_FILTER {

    tag "$sample"

    publishDir "${params.outdir}/filterencode/samtools_sort_index_post_encode_filter", mode: 'copy'

    input:
    tuple val(sample), val(replicate), val(sequencing_type), path(no_dups_filtered_bam)
    
    output:
    tuple val(sample),
          val(replicate),
          val(sequencing_type),
          path("*no_dups.filtered.sorted.bam"),
          path("*no_dups.filtered.sorted.bai"),
          path("*flagstats.txt"),
          path("*idxstats.txt"),
          path("*stats.txt")

    script:
    
    """
    echo "Sorting BAM for sample: ${sample}_${replicate}"
    samtools sort ${no_dups_filtered_bam} -o ${sample}_${replicate}.no_dups.filtered.sorted.bam

    echo "Indexing BAM for sample: ${sample}_${replicate}"
    samtools index ${sample}_${replicate}.no_dups.filtered.sorted.bam ${sample}_${replicate}.no_dups.filtered.sorted.bai
    
    echo "Computing alignment stats for sample: ${sample}_${replicate}"
    samtools flagstat ${sample}_${replicate}.no_dups.filtered.sorted.bam > ${sample}_${replicate}.no_dups.filtered_flagstats.txt

    echo "Computing alignment summary stats for sample: ${sample}_${replicate}"
    samtools idxstats ${sample}_${replicate}.no_dups.filtered.sorted.bam > ${sample}_${replicate}.no_dups.filtered_idxstats.txt

    echo "Computing mapping and alignment stats for sample: ${sample}_${replicate}"
    samtools stats ${sample}_${replicate}.no_dups.filtered.sorted.bam > ${sample}_${replicate}.no_dups.filtered_stats.txt

    """    
}

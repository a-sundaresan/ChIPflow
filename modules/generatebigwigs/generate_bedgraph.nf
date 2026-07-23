process GENERATE_BEDGRAPH {

    tag "$sample"

    publishDir "${params.outdir}/generatebigwigs/bedgraph", mode: 'copy'

    input:
    tuple val(sample), val(replicate), val(sequencing_type), path(no_dups_filtered_sorted_bam)
    
    output:
    tuple val(sample),
          val(replicate),
          val(sequencing_type),
          path("*filtered.bedGraph"),
          path("*sorted.bedGraph")

    script:
    
    """
    echo "Generating BEDGRAPH for sample: ${sample}_${replicate}"
    bedtools genomecov -ibam ${sample}_${replicate}.no_dups.filtered.sorted.bam \
                       -bga > ${sample}_${replicate}.no_dups.filtered.bedGraph

    echo "Sorting BEDGRAPH for sample: ${sample}_${replicate}"
    sort -k1,1 -k2,2n ${sample}_${replicate}.no_dups.filtered.bedGraph > ${sample}_${replicate}.no_dups.filtered.sorted.bedGraph
    
    """    
}

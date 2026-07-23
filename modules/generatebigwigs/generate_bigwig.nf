process GENERATE_BIGWIG {

    tag "$sample"

    publishDir "${params.outdir}/generatebigwigs/bigwigs", mode: 'copy'

    input:
    tuple val(sample), val(replicate), val(sequencing_type), path(sorted_bedgraph)
    
    output:
    tuple val(sample),
          val(replicate),
          val(sequencing_type),
          path("*filtered.sorted.bw")

    script:
    
    """
    echo "Generating BIGWIG for sample: ${sample}_${replicate}"
    bedGraphToBigWig ${sample}_${replicate}.no_dups.filtered.sorted.bedGraph \
                     ${params.chrom_size} \
                     ${sample}_${replicate}.no_dups.filtered.sorted.bw

    """    
}

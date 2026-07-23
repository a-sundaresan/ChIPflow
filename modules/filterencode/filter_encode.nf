process FILTER_ENCODE {

    tag "$sample"

    publishDir "${params.outdir}/filterencode/encodefiltered", mode: 'copy'

    input:
    tuple val(sample), val(replicate), val(sequencing_type), path(nodups_bam)
    
    output:
    tuple val(sample),
          val(replicate),
          val(sequencing_type),
          path("*no_dups.filtered.bam")

    script:
    
    """
    
    echo "Filtering ENCODE blacklist regions for sample: ${sample}_${replicate}"
    bedtools intersect -abam ${nodups_bam} \\
             -b ${params.encode_blacklist} -v > ${sample}_${replicate}.no_dups.filtered.bam
    
    """
}

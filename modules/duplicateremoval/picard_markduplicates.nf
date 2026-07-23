process PICARD_MARKDUPLICATES {

    tag "$sample"

    publishDir "${params.outdir}/duplicateremoval/picard_markduplicates", mode: 'copy'

    input:
    tuple val(sample), val(replicate), val(sequencing_type), path(filtered_bam)
    
    output:
    tuple val(sample),
          val(replicate),
          val(sequencing_type),
          path("*markdup.bam"),
          path("*metrics.txt")

    script:
    
    //Define the variable in Groovy before using it
    def basename = filtered_bam.baseName

    """
    echo "Marking duplicates (Picard) for sample: ${sample}_${replicate}"

    picard \\
        -Xmx${task.memory.toGiga()}g \\
        MarkDuplicates \\
        --INPUT ${filtered_bam} \\
        --OUTPUT ${basename}.markdup.bam \\
        --METRICS_FILE ${basename}.MarkDuplicates.metrics.txt

    """    
}

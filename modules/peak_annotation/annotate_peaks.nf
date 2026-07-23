process ANNOTATE_PEAKS {
    
    tag "$sample"

    publishDir "${params.outdir}/peak_annotate/peak_annotatation", mode: 'copy'
  
    
    input:
    tuple val(sample), val(replicate), val(seqtype), file(narrowpeak)
    
    output:
    tuple val(sample),
          val(replicate),
          val(seqtype),
          path("${sample}_${replicate}_peaks_annotation_stats.txt"),
          path("${sample}_${replicate}_peaks_annotation.txt"),
          path("${sample}_${replicate}_peaks_modified.bed") 

    script:

    """

    awk -F"\t" '{print \$1"\t"\$2"\t"\$3"\t""peak_"NR}' \
               ${narrowpeak} > ${sample}_${replicate}_peaks_modified.bed
    
    annotatePeaks.pl ${sample}_${replicate}_peaks_modified.bed \
                     ${params.fasta} \
                     -gtf ${params.gtf} \
                     -annStats ${sample}_${replicate}_peaks_annotation_stats.txt > ${sample}_${replicate}_peaks_annotation.txt

    """
}

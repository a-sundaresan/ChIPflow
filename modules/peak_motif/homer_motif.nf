process PEAK_MOTIF {
    
    tag "$sample"

    publishDir "${params.outdir}/peak_motif/homer_motif", mode: 'copy'
  
    
    input:
    tuple val(sample), val(replicate), val(seqtype), file(narrowpeak)
    
    output:
    tuple val(sample),
          val(replicate),
          val(seqtype),
          path("${sample}_${replicate}_*"),
          path("${sample}_${replicate}_peaks_modified.bed") 

    script:

    """

    awk -F"\t" '{print \$1"\t"\$2"\t"\$3"\t""peak_"NR}' \
               ${narrowpeak} > ${sample}_${replicate}_peaks_modified.bed
    

    findMotifsGenome.pl ${sample}_${replicate}_peaks_modified.bed \
                        ${params.fasta} \
                        ${sample}_${replicate}_motif \
                        -size 200
    """
}

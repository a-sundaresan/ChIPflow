process CALL_PEAKS {
    
    tag "$sample"

    publishDir "${params.outdir}/peak_calling/peaks", mode: 'copy'
  
    
    input:
    tuple val(sample), val(replicate), val(seqtype), file(chip_bam), file(control_bams)
    
    output:
    tuple val(sample),
          val(replicate),
          val(seqtype),
          path("${sample}_${replicate}_peaks.xls"),
          path("${sample}_${replicate}_peaks.narrowPeak"),
          path("${sample}_${replicate}_summits.bed"),
          path("${sample}_${replicate}_model.r") 

    script:

        def format = seqtype == 'PE' ? 'BAMPE' : 'BAM'
        //def broad_flag = params.macs2_broad_peak ? "--broad" : ""
    
    """
    macs2 callpeak \
        -t ${chip_bam} \
        -c ${control_bams} \
        -n ${sample}_${replicate} \
        -f ${format} \
        -g ${params.macs2_genome_size}
    """
}

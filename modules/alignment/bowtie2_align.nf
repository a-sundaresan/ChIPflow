process BOWTIE2_ALIGN {

    tag "$sample"

    publishDir "${params.outdir}/alignment/BOWTIE2", mode: 'copy'

    input:
    tuple val(sample), val(replicate), val(sequencing_type), path(deduplicated_fastqs)
    
    output:
    tuple val(sample),
          val(replicate),
          val(sequencing_type),
          path("${sample}_${replicate}_bowtie2_Aligned.out.sam")

    script:
    if (sequencing_type == "PE") {    

    """
    echo "Running BOWTIE2 alignment for PE sample: ${sample}_${replicate}"
    echo "Sequencing type is : ${sequencing_type}"

    bowtie2 -x ${params.bowtie2_index} \
            -1 ${deduplicated_fastqs[0]} \
            -2 ${deduplicated_fastqs[1]} \
            --rg-id ${sample}_${replicate} --rg SM:${sample} --rg PL:ILLUMINA --rg LB:${sample} --rg PU:${sample}_${replicate} \
            -S ${sample}_${replicate}_bowtie2_Aligned.out.sam

    """
       }
     else {

      """
      echo "Running BOWTIE2 alignment for SE sample: ${sample}_${replicate}"
      echo "Sequencing type is : ${sequencing_type}"

      bowtie2 -x ${params.bowtie2_index} \
              -U ${deduplicated_fastqs[0]} \
              --rg-id ${sample}_${replicate} --rg SM:${sample} --rg PL:ILLUMINA --rg LB:${sample} --rg PU:${sample}_${replicate} \
              -S ${sample}_${replicate}_bowtie2_Aligned.out.sam
      """
    }
    
}

process STAR_ALIGN {

    tag "$sample"

    publishDir "${params.outdir}/alignment/STAR", mode: 'copy'

    input:
    tuple val(sample), val(replicate), val(sequencing_type), path(deduplicated_fastqs)
    
    output:
    tuple val(sample),
          val(replicate),
          val(sequencing_type),
          path("${sample}_${replicate}_STAR_Aligned.out.sam")

    script:

    if (sequencing_type == "PE") {    
    """
    echo "Running STAR alignment for PE sample: ${sample}_${replicate}"
    echo "Sequencing type is : ${sequencing_type}"
    STAR \
            --runThreadN ${task.cpus} \
            --genomeDir ${params.STAR_genomeDir} \
            --readFilesIn ${deduplicated_fastqs[0]} ${deduplicated_fastqs[1]} \
            --readFilesCommand zcat \
            --outFileNamePrefix ${sample}_${replicate}_STAR_ \
            --outSAMtype SAM
     """
       } 
     else {
      """
      echo "Running STAR alignment for SE sample: ${sample}_${replicate}"
      echo "Sequencing type is : ${sequencing_type}"
      STAR \
            --runThreadN ${task.cpus} \
            --genomeDir ${params.STAR_genomeDir} \
            --readFilesIn ${deduplicated_fastqs[0]} \
            --readFilesCommand zcat \
            --outFileNamePrefix ${sample}_${replicate}_STAR_ \
            --outSAMtype SAM      
      """
    }
    
}

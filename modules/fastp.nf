process FASTP {

    tag "$sample"

    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
    tuple val(sample), val(replicate), path(fastq)

    output:
    tuple val(sample), val(replicate), val(sequencing_type),
          path("*fastp.deduplicated.fastq.gz"),
          file("${sample}_${replicate}_fastp.html"),
          file("${sample}_${replicate}_fastp.json")

    script:

        if (fastq.size() == 2) {
            sequencing_type="PE"
        }else{
            sequencing_type="SE"
        }

        if (sequencing_type == "PE") {

        """
        echo "Running FASTP for PE sample: ${sample}_${replicate}"
        echo "Input reads: ${fastq[0]} ${fastq[1]}"
        
        fastp \
            -i ${fastq[0]} \
            -I ${fastq[1]} \
            -o ${sample}_${replicate}_R1_fastp.deduplicated.fastq.gz \
            -O ${sample}_${replicate}_R2_fastp.deduplicated.fastq.gz \
            --dedup \
            --detect_adapter_for_pe \
            --html ${sample}_${replicate}_fastp.html \
            --json ${sample}_${replicate}_fastp.json \
            --report_title '${sample}_${replicate}'
        """
     } 
     else {        
        """
        echo "Running FASTP for SE sample: ${sample}_${replicate}"
        echo "Input read: ${fastq[0]}"

        fastp \
            -i ${fastq[0]} \
            -o ${sample}_${replicate}_R1_fastp.deduplicated.fastq.gz \
            --dedup \
            --html ${sample}_${replicate}_fastp.html \
            --json ${sample}_${replicate}_fastp.json \
            --report_title '${sample}_${replicate}'
        """
    }
}

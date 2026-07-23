process SAMTOOLS_SORT_INDEX {

    tag "$sample"

    publishDir "${params.outdir}/alignment/samtools_sort_index", mode: 'copy'

    input:
    tuple val(sample), val(replicate), val(sequencing_type), path(aligned_sam)
    
    output:
    tuple val(sample),
          val(replicate),
          val(sequencing_type),
          path("*filtered.bam")

    script:
    
    //Define the variable in Groovy before using it
    def basename = aligned_sam.baseName

    """
    echo "Converting SAM TO BAM for sample: ${sample}_${replicate}"
    echo "Sequencing type is : ${sequencing_type}"
    samtools view -bh -S ${aligned_sam} > ${basename}.unsorted.bam 

    echo "Sorting BAM for sample: ${sample}_${replicate}"
    samtools sort ${basename}.unsorted.bam -o ${basename}.sorted.bam
    
    # Remove unmapped, mate unmapped
    # not primary alignment, reads failing platform
    # Remove low MAPQ reads
    # Obtain name sorted BAM file
     if [ $sequencing_type = 'SE' ]; then
          samtools view -F 1804 -q 30 -b ${basename}.sorted.bam > ${basename}.sorted.filtered.bam
      else
          samtools view -F 1804 -f 2 -q 30 -u ${basename}.sorted.bam | samtools sort -n - -o ${basename}.tmp
          #fill in mate coordinates, ISIZE and mate-related flags
	  #fixmate requires name-sorted alignment; -r removes secondary and unmapped (redundant here because already done above?)
	  #- send output to stdout
          samtools fixmate -r ${basename}.tmp - | samtools view -F 1804 -f 2 -u - | samtools sort - -o ${basename}.sorted.filtered.bam
          rm ${basename}.tmp
     fi

    #echo "Indexing BAM for sample: ${sample}_${replicate}"
    #samtools index ${basename}.sorted.bam -o ${basename}.sorted.bai

    #echo "Generating alignment statistics for sample: ${sample}_${replicate}"
    #samtools flagstat ${basename}.sorted.bam > ${basename}.sorted_stats.txt
    
    """    
}

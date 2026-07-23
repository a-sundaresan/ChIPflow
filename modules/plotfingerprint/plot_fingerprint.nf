process PLOT_FINGERPRINT {

    tag "all_samples"

    publishDir "${params.outdir}/plotfingerprint/fingerprint_plots", mode: 'copy'

    input:
    file bam_files

    output:
    path("*plotFingerprint.pdf")
    path("*plotFingerprint.metrics.txt")
    path("*plotFingerprint.raw.txt")

    script:

    """
    echo "FingerPrint plot for all samples"

    plotFingerprint \
        --bamfiles ${bam_files.findAll { it.name.endsWith('.bam') }.join(' ')} \
        --labels ${bam_files.findAll { it.name.endsWith('.bam') }.collect { it.baseName.replaceFirst(/\..*/, '') }.join(' ')} \
        --numberOfProcessors ${task.cpus} \
        --plotFile all_samples.plotFingerprint.pdf \
        --outRawCounts all_samples.plotFingerprint.raw.txt \
        --outQualityMetrics all_samples.plotFingerprint.metrics.txt    
    
    """    
}

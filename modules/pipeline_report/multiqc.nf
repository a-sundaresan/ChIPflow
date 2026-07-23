process MULTIQC {

    tag "multiqc"

    publishDir "${params.outdir}/project_reporting/multiqc", mode: 'copy'



      input:
      path(qc_files)

      output:
      path "multiqc*"

      script:
      """
      multiqc . \
              --filename multiqc_report.html \
              --force

      """

}

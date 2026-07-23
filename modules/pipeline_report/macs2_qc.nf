process MACS2_QC {

    tag "macs2_qc"

    publishDir "${params.outdir}/peak_calling/qc", mode: 'copy'

    input:
    path(xls_files)

    output:
    path("macs2_peaks_mqc.txt")

    script:
    """
    {
        echo "# id: 'macs2_peak_count'"
        echo "# section_name: 'MACS2 Peak Calling'"
        echo "# description: 'Number of peaks called per sample by MACS2'"
        echo "# plot_type: 'bargraph'"
        echo "# pconfig:"
        echo "#     id: 'macs2_peak_count_plot'"
        echo "#     title: 'MACS2: Number of Peaks'"
        echo "#     ylab: 'Number of peaks'"
        echo "#     tt_decimals: 0"
        printf 'Sample\tPeaks\n'
        for xls in ${xls_files}; do
            sample=\$(basename "\$xls" _peaks.xls)
            count=\$(grep -v "^#" "\$xls" | tail -n +2 | wc -l | tr -d ' ')
            printf '%s\t%s\n' "\$sample" "\$count"
        done
    } > macs2_peaks_mqc.txt
    """
}

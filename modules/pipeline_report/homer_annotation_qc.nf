process HOMER_ANNOTATION_QC {

    tag "homer_annotation_qc"

    publishDir "${params.outdir}/peak_annotate/qc", mode: 'copy'

    input:
    path(stats_files)

    output:
    path("homer_annotation_mqc.txt")

    script:
    """
    cat << 'PYEOF' > parse_homer_annotation.py
import sys, os

files = sys.argv[1:]
all_cats = []
seen = set()
sample_data = {}

for f in files:
    sample = os.path.basename(f).replace("_peaks_annotation_stats.txt", "")
    sample_data[sample] = {}
    with open(f) as fh:
        fh.readline()  # skip header line
        for line in fh:
            parts = line.strip().split("\\t")
            if len(parts) < 3:
                continue
            cat = parts[0].strip()
            if cat == "Annotation":
                continue
            try:
                count = int(float(parts[1].strip()))
            except ValueError:
                continue
            sample_data[sample][cat] = count
            if cat not in seen:
                seen.add(cat)
                all_cats.append(cat)

header_lines = [
    "# id: 'homer_annotation'",
    "# section_name: 'HOMER Peak Annotation'",
    "# description: 'Distribution of peaks across genomic features per sample (from annotatePeaks.pl -annStats)'",
    "# plot_type: 'bargraph'",
    "# pconfig:",
    "#     id: 'homer_annotation_plot'",
    "#     title: 'HOMER: Peak Annotation'",
    "#     ylab: 'Number of peaks'",
]

with open("homer_annotation_mqc.txt", "w") as out:
    for h in header_lines:
        out.write(h + "\\n")
    out.write("Sample\\t" + "\\t".join(all_cats) + "\\n")
    for sample in sorted(sample_data):
        row = [sample] + [str(sample_data[sample].get(c, 0)) for c in all_cats]
        out.write("\\t".join(row) + "\\n")
PYEOF
    python3 parse_homer_annotation.py ${stats_files}
    """
}

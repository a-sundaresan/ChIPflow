process HOMER_MOTIF_QC {

    tag "homer_motif_qc"

    publishDir "${params.outdir}/peak_motif/qc", mode: 'copy'

    input:
    path(motif_files)

    output:
    path("homer_motifs_mqc.txt")

    script:
    """
    cat << 'PYEOF' > parse_homer_motifs.py
import sys, os, glob

# knownResults.txt columns (0-indexed):
#  0: Motif Name  (e.g. "CTCF(Zf)/source/Homer")
#  4: q-value (Benjamini)
#  6: % of Target Sequences with Motif

TOP_N = 3

results = {}  # sample -> list of (motif, pct_target, qvalue) for top N

for kr_file in sorted(glob.glob("**/knownResults.txt", recursive=True)):
    # Derive sample name from parent directory: remove trailing _motif
    parent = os.path.basename(os.path.dirname(kr_file))
    sample = parent[:-6] if parent.endswith("_motif") else parent

    hits = []
    with open(kr_file) as fh:
        fh.readline()  # skip header
        for line in fh:
            parts = line.strip().split("\\t")
            if len(parts) < 7:
                continue
            full_name = parts[0].strip()
            motif_name = full_name.split("/")[0]   # keep only "TF(family)" part
            try:
                qval = float(parts[4].strip())
                pct  = float(parts[6].strip().rstrip("%"))
            except ValueError:
                continue
            hits.append((motif_name, pct, qval))
            if len(hits) == TOP_N:
                break

    results[sample] = hits

# Build column headers for top N ranks
cols = []
for i in range(1, TOP_N + 1):
    cols += [f"#{i} Motif", f"#{i} % Target", f"#{i} q-value"]

header_lines = [
    "# id: 'homer_known_motifs'",
    "# section_name: 'HOMER Known Motif Enrichment'",
    "# description: 'Top enriched known motifs per sample from findMotifsGenome.pl (knownResults.txt)'",
    "# plot_type: 'table'",
    "# pconfig:",
    "#     id: 'homer_known_motifs_table'",
    "#     title: 'HOMER: Top Known Motifs'",
]

with open("homer_motifs_mqc.txt", "w") as out:
    for h in header_lines:
        out.write(h + "\\n")
    out.write("Sample\\t" + "\\t".join(cols) + "\\n")
    for sample in sorted(results):
        row = [sample]
        for i in range(TOP_N):
            if i < len(results[sample]):
                motif, pct, qval = results[sample][i]
                row += [motif, str(round(pct, 2)), str(qval)]
            else:
                row += ["NA", "NA", "NA"]
        out.write("\\t".join(row) + "\\n")
PYEOF
    python3 parse_homer_motifs.py
    """
}

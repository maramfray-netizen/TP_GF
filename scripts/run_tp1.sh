#!/usr/bin/env bash
set -euo pipefail
ACC=DRR187559
cd "$(dirname "$0")/.."
mkdir -p raw qc/raw qc/trim trimmed asm quast checkm2 prokka bakta ref amr results

# 1. Download reads (env: asm)
prefetch $ACC
fasterq-dump $ACC --split-files -e 4 -O raw
gzip -f raw/*.fastq

# 2. Quality control and trimming (env: asm)
fastqc raw/*.fastq.gz --outdir qc/raw -t 4
fastp -i raw/${ACC}_1.fastq.gz -I raw/${ACC}_2.fastq.gz \
      -o trimmed/R1.fq.gz -O trimmed/R2.fq.gz \
      --detect_adapter_for_pe --qualified_quality_phred 20 --length_required 30 \
      --html qc/fastp.html --json qc/fastp.json -w 4
fastqc trimmed/*.fq.gz --outdir qc/trim -t 4
multiqc qc -o qc/multiqc
seqkit stats raw/*.fastq.gz trimmed/*.fq.gz > results/read_stats.txt

# 3. Assembly with SPAdes directly (Shovill requires >= 8 GB RAM) (env: asm)
spades.py -1 trimmed/R1.fq.gz -2 trimmed/R2.fq.gz -o asm_spades -t 4 -m 3 --isolate
cp asm_spades/contigs.fasta asm/contigs.fa
cp asm_spades/assembly_graph_with_scaffolds.gfa asm/contigs.gfa
seqkit stats asm/contigs.fa > results/assembly_stats.txt

# 4. QUAST (env: asm)
efetch -db nuccore -id AP020324 -format fasta > ref/AP020324.fa
efetch -db nuccore -id AP020325 -format fasta > ref/AP020325.fa
cat ref/AP020324.fa ref/AP020325.fa > ref/ref.fa
quast.py asm/contigs.fa -r ref/ref.fa -o quast -t 4 --min-contig 500
cp quast/report.tsv results/quast_report.tsv
cp quast/report.html results/quast_report.html

# 5. CheckM2 (env: checkm2)
#   checkm2 predict -i asm/contigs.fa -o checkm2 -t 2 --lowmem --database_path ~/db/CheckM2_database/uniref100.KO.1.dmnd --force
#   cp checkm2/quality_report.tsv results/

# 6. Annotation (env: prokka, bakta)
#   prokka --outdir prokka --prefix KUN1163 --kingdom Bacteria --genus Staphylococcus --species aureus --strain KUN1163 --cpus 2 --force asm/contigs.fa
#   bakta --db ~/db/db-light --output bakta --prefix KUN1163 --genus Staphylococcus --species aureus --threads 2 --force asm/contigs.fa

# 7. mecA detection (env: prokka)
#   amrfinder -n asm/contigs.fa -O Staphylococcus_aureus --plus -o amr/amr.tsv
#   cp amr/amr.tsv results/

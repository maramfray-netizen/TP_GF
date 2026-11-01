# TP_GF: De novo assembly and annotation of a *Staphylococcus aureus* genome (SRA run DRR187559)

Practical work for the M2 Bioinformatics programme (omics data analysis).
The course handout uses Galaxy; this repository reproduces the same workflow on the command line (WSL + conda + VS Code).

## Objective
Assemble the genome of *S. aureus* from Illumina paired-end reads, assess assembly quality,
annotate the genome, and look for the methicillin-resistance gene *mecA*.

## Data
- SRA run: DRR187559 (Illumina MiSeq, 2 x 300 bp, paired-end)
- Reference genome: *S. aureus* KUN1163 (chromosome AP020324, plasmid AP020325)
- Raw data and large files are not tracked in this repository (see `.gitignore`).

## Tools
SRA Toolkit, FastQC, fastp, MultiQC, SeqKit, SPAdes, QUAST, CheckM2, Prokka, Bakta, AMRFinderPlus, BLAST, Bandage.
Conda environments are exported in `envs/`.

## Workflow
1. Download reads (`prefetch`, `fasterq-dump`)
2. Quality control before and after trimming (FastQC, fastp, MultiQC)
3. De novo assembly (SPAdes, `--isolate` mode)
4. Assessment (QUAST, CheckM2)
5. Annotation (Prokka, Bakta)
6. *mecA* detection (AMRFinderPlus, BLAST)

## Reproduce

    conda env create -f envs/asm.yml
    conda activate asm
    bash scripts/run_tp1.sh

## Key results

| Metric | Value |
|---|---|
| Raw reads (R1 + R2) | 903,564 |
| Contigs (>= 500 bp, QUAST) | 32 (43 in total) |
| Total length | 2,905,152 bp (reference: 2,944,787 bp) |
| Largest contig | 416,029 bp |
| N50 / L50 | 276,382 bp / 5 |
| NGA50 | 178,073 bp |
| Genome fraction | 98.62 % |
| Misassemblies | 3 |
| GC content | 32.77 % (reference: 32.87 %) |
| CheckM2 completeness / contamination | 100.0 % / 0.74 % |

Annotation (Prokka vs Bakta) and *mecA* results are stored in `results/`.

## Notes and limitations
- Shovill requires at least 8 GB of RAM, while the WSL machine provides about 2.8 GB.
  SPAdes was therefore run directly (`--isolate`, 3 GB limit) on reads trimmed with fastp.
- CheckM2 was run with `--lowmem` and 2 threads for the same reason.
- The assembly graph (`contigs.gfa`) was inspected with Bandage on Windows.

## Repository structure

    scripts/   workflow script (run_tp1.sh)
    envs/      exported conda environments
    results/   lightweight reports and tables

## Author
Maram Fray, M2 Bioinformatics (ISBST / ENSI / IPT)
Contact: maram.fray@ensi-uma.tn | GitHub: [maramfray-netizen](https://github.com/maramfray-netizen)

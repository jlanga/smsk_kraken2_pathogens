# Snakemake workflow: `mg_quant`

[![Snakemake](https://img.shields.io/badge/snakemake-≥8.0.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/jlanga/smsk_kraken2_pathogens/workflows/Tests/badge.svg)](https://github.com/jlanga/smsk_kraken2_pathogens/actions)


A Snakemake workflow for assessing detection limit from laser-microdissected samples.

## Usage

0. Requirements
   1.  [`miniconda`](https://docs.conda.io/en/latest/miniconda.html) / [`mamba`](https://mamba.readthedocs.io)
   2.  [`snakemake`](snakemake.readthedocs.io/)

1. Clone the repository
Clone the repository, and set it as the working directory.

```
git clone --recursive https://github.com/jlanga/smsk_kraken2_pathogens
cd detection_limit_test
```

2. Run the pipeline with the test data (takes 5 minutes to download the required software)
```
snakemake \
    --use-conda \
    --conda-frontend mamba \
    -j 8
```

3. Edit the following files:
   1. `config/samples.tsv`: the control file with the sequencing libraries and their location.
      ```
      sample_id	library_id	forward_filename	reverse_filename	forward_adapter	reverse_adapter
      sample1	lib1	resources/reads/sample1_1.fq.gz	resources/reads/sample1_2.fq.gz	AGATCGGAAGAGCACACGTCTGAACTCCAGTCA	AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
      sample2	lib1	resources/reads/sample2_1.fq.gz	resources/reads/sample2_2.fq.gz	AGATCGGAAGAGCACACGTCTGAACTCCAGTCA	AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
      ```
   2. `config/features.yml`: the references and databases against which to screen the libraries: human, chicken / pig, MAG catalogue.
      ```
      references:  # Reads will be mapped sequentially
         human: resources/reference/human_22_sub.fa.gz
         chicken: resources/reference/chicken_39_sub.fa.gz
      pathogens:
         gonorrhea:
            fasta: resources/reference/gonorrhea.fa.gz
            taxid: 485
         syphilis:
            fasta: resources/reference/syphilis.fa.gz
            taxid: 545776

      databases:
         kraken2:
            mock1: resources/databases/kraken2/kraken2_RefSeqV205_Complete_500GB
      ```

   1. `config/params.yml`: parameters for every program. The defaults are reasonable.


4. Run the pipeline and go for a walk:

```
snakemake --use-conda -j 8
```

## Rulegraph

![rulegraph](rulegraph_simple.svg)

## Brief description

1. Trim reads and remove adaptors with `fastp`
2. Map to host(s):
   1. Map to the reference with `bowtie2`
   2. Extract the reads that have one of both ends unmapped with `samtools`
   3. Map those unmapped reads to the next reference
3. Classify reads with `kraken2`
4. Extract pathogenic reads
5. Map extracted reads to genome
6. Generate lots of reports in the `reports/` folder


## References

- [fastp](https://github.com/OpenGene/fastp)
- [bowtie2](https://bowtie-bio.sourceforge.net/bowtie2/manual.shtml)
- [samtools](https://www.htslib.org/)
- [coverm](https://github.com/wwood/CoverM)
- [fastqc](https://github.com/s-andrews/FastQC)
- [multiqc](https://multiqc.info/)
- [kraken2](https://github.com/DerrickWood/kraken2)

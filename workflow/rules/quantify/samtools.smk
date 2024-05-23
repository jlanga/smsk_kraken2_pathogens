rule quantify__samtools__stats__cram_pathogen__:
    """Compute stats for a pathogen cram"""
    input:
        cram=QUANT_BOWTIE2 / "{kraken2_db}" / "{pathogen}" / "{sample}.{library}.cram",
        crai=QUANT_BOWTIE2 / "{kraken2_db}"/ "{pathogen}" / "{sample}.{library}.cram.crai",
        reference=REFERENCE / "pathogens" / "{pathogen}.fa.gz",
    output:
        tsv=QUANT_BOWTIE2 / "{kraken2_db}" / "{pathogen}" / "{sample}.{library}.stats.tsv",
    log:
        QUANT_BOWTIE2 / "{kraken2_db}" / "{pathogen}" / "{sample}.{library}.stats.log",
    conda:
        "__environment__.yml"
    shell:
        """
        samtools stats \
            --reference {input.reference} \
            {input.cram} \
        > {output.tsv} \
        2> {log}
        """

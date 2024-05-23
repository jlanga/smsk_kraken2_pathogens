rule quantify__bowtie2__:
    """Map one library to reference genome using bowtie2"""
    input:
        forward_=K2_EXTRACT / "{kraken2_db}" / "{pathogen}" / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=K2_EXTRACT / "{kraken2_db}" / "{pathogen}" / "{sample_id}.{library_id}_2.fq.gz",
        mock=multiext(
            str(QUANT_INDEX) + "/{pathogen}",
            ".1.bt2l",
            ".2.bt2l",
            ".3.bt2l",
            ".4.bt2l",
            ".rev.1.bt2l",
            ".rev.2.bt2l",
        ),
        reference=REFERENCE / "pathogens" / "{pathogen}.fa.gz",
        fai=REFERENCE / "pathogens" / "{pathogen}.fa.gz.fai",
        gzi=REFERENCE / "pathogens" / "{pathogen}.fa.gz.gzi",
    output:
        cram=QUANT_BOWTIE2 / "{kraken2_db}" / "{pathogen}" / "{sample_id}.{library_id}.cram",
    log:
        QUANT_BOWTIE2 / "{kraken2_db}" / "{pathogen}" / "{sample_id}.{library_id}.log",
    conda:
        "__environment__.yml"
    params:
        samtools_mem=params["quantify"]["bowtie2"]["samtools_mem"],
        rg_id=compose_rg_id,
        rg_extra=compose_rg_extra,
        index=lambda w: QUANT_INDEX / f"{w.pathogen}",
    retries: 5
    shell:
        """
        ( bowtie2 \
            -x {params.index} \
            -1 {input.forward_} \
            -2 {input.reverse_} \
            --rg '{params.rg_extra}' \
            --rg-id '{params.rg_id}' \
            --threads {threads} \
        | samtools sort \
            --output-fmt CRAM \
            --reference {input.reference} \
            --threads {threads} \
            -T {output.cram} \
            -m {params.samtools_mem} \
            -o {output.cram} \
        ) 2> {log} 1>&2
        """


rule quantify__bowtie2:
    """Run bowtie2 over all mag catalogues and samples"""
    input:
        [
            QUANT_BOWTIE2 / kraken2_db / pathogen / f"{sample_id}.{library_id}.cram"
            for sample_id, library_id in SAMPLE_LIBRARY
            for pathogen in PATHOGENS
            for kraken2_db in KRAKEN2_DBS
        ],

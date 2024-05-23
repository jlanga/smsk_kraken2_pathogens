rule quantify__index__:
    """Build bowtie2 index for the mag reference

    Let the script decide to use a small or a large index based on the size of
    the reference genome.
    """
    input:
        reference=REFERENCE / "pathogens" / "{pathogen}.fa.gz",
    output:
        multiext(
            str(QUANT_INDEX) + "/{pathogen}",
            ".1.bt2l",
            ".2.bt2l",
            ".3.bt2l",
            ".4.bt2l",
            ".rev.1.bt2l",
            ".rev.2.bt2l",
        ),
    log:
        QUANT_INDEX / "{pathogen}.log",
    conda:
        "__environment__.yml"
    params:
        prefix=lambda w: str(QUANT_INDEX / f"{w.pathogen}"),
    retries: 5
    cache: "omit-software"
    shell:
        """
        bowtie2-build \
            --large-index \
            --threads {threads} \
            {input.reference} \
            {params.prefix} \
        2> {log} 1>&2
        """


rule quantify__index:
    input:
        [
            QUANT_INDEX / f"{pathogen}.{end}"
            for end in [
                "1.bt2l",
                "2.bt2l",
                "3.bt2l",
                "4.bt2l",
                "rev.1.bt2l",
                "rev.2.bt2l",
            ]
            for pathogen in PATHOGENS
        ],

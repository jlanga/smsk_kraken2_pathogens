rule reference__recompress__host__:
    """Extract the fasta.gz on config.yaml into genome.fa,gz with bgzip"""
    input:
        fa_gz=lambda w: features["references"][w.genome],
    output:
        fa_gz=REFERENCE / "{genome}.fa.gz",
    log:
        REFERENCE / "{genome}.log",
    conda:
        "__environment__.yml"
    cache: "omit-software"
    shell:
        """
        ( gzip \
            --decompress \
            --stdout {input.fa_gz} \
        | bgzip \
            --compress-level 9 \
            --threads {threads} \
            --stdout \
            /dev/stdin \
        > {output.fa_gz} \
        ) 2> {log}
        """


rule reference__recompress__pathogens__:
    """Extract the fasta.gz on config.yaml into genome.fa,gz with bgzip"""
    input:
        fa_gz=lambda w: features["pathogens"][w.pathogen]["fasta"],
    output:
        fa_gz=REFERENCE / "pathogens" / "{pathogen}.fa.gz",
    log:
        REFERENCE / "pathogens" / "{pathogen}.log",
    conda:
        "__environment__.yml"
    cache: "omit-software"
    shell:
        """
        ( gzip \
            --decompress \
            --stdout {input.fa_gz} \
        | bgzip \
            --compress-level 9 \
            --threads {threads} \
            --stdout \
            /dev/stdin \
        > {output.fa_gz} \
        ) 2> {log}
        """


rule reference__recompress__hosts:
    """Recompress all host genomes"""
    input:
        [REFERENCE / f"{genome}.fa.gz" for genome in HOST_NAMES],


rule reference__recompress__pathogens:
    """Recompress all MAG catalogues"""
    input:
        [REFERENCE / "pathogens" / f"{pathogen}.fa.gz" for pathogen in PATHOGENS],


rule reference__recompress:
    input:
        rules.reference__recompress__hosts.input,
        rules.reference__recompress__pathogens.input,

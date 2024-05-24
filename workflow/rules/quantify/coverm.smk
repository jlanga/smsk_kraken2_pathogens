rule quantify__coverm__genome__:
    """Run coverm genome for one library and one mag catalogue"""
    input:
        cram=QUANT_BOWTIE2
        / "{kraken2_db}"
        / "{pathogen}"
        / "{sample_id}.{library_id}.cram",
        crai=QUANT_BOWTIE2
        / "{kraken2_db}"
        / "{pathogen}"
        / "{sample_id}.{library_id}.cram.crai",
        reference=REFERENCE / "pathogens" / "{pathogen}.fa.gz",
        fai=REFERENCE / "pathogens" / "{pathogen}.fa.gz.fai",
    output:
        tsv=touch(
            COVERM
            / "{kraken2_db}"
            / "{pathogen}/genome/{method}/{sample_id}.{library_id}.tsv"
        ),
    conda:
        "__environment__.yml"
    log:
        COVERM
        / "{kraken2_db}"
        / "{pathogen}/genome/{method}/{sample_id}.{library_id}.log",
    params:
        method="{method}",
        min_covered_fraction=params["quantify"]["coverm"]["genome"][
            "min_covered_fraction"
        ],
        separator=params["quantify"]["coverm"]["genome"]["separator"],
    shell:
        """
        ( samtools view \
            --with-header \
            --reference {input.reference} \
            {input.cram} \
        | coverm genome \
            --bam-files /dev/stdin \
            --methods {params.method} \
            --separator "{params.separator}" \
            --min-covered-fraction {params.min_covered_fraction} \
            --output-file {output.tsv} \
        ) 2> {log} 1>&2
        """


rule quantify__coverm__genome__aggregate:
    """Aggregate all the nonpareil results into a single table"""
    input:
        get_coverm_genome_tsv_files_for_aggregation,
    output:
        COVERM / "{kraken2_db}" / "coverm_genome_{pathogen}.{method}.tsv",
    log:
        COVERM / "{kraken2_db}" / "coverm_genome_{pathogen}.{method}.log",
    conda:
        "__environment__.yml"
    params:
        input_dir=lambda w: COVERM / w.kraken2_db / w.pathogen / "genome" / w.method,
    shell:
        """
        Rscript --no-init-file workflow/scripts/aggregate_coverm.R \
            --input-folder {params.input_dir} \
            --output-file {output} \
        2> {log} 1>&2
        """


rule quantify__coverm__genome:
    """Run all rules to run coverm genome over all MAG catalogues"""
    input:
        [
            COVERM / kraken2_db / f"coverm_genome_{pathogen}.{method}.tsv"
            for pathogen in PATHOGENS
            for method in params["quantify"]["coverm"]["genome"]["methods"]
            for kraken2_db in KRAKEN2_DBS
        ],


rule quantify__coverm__contig__:
    """Run coverm contig for one library and one mag catalogue"""
    input:
        cram=QUANT_BOWTIE2
        / "{kraken2_db}"
        / "{pathogen}"
        / "{sample_id}.{library_id}.cram",
        crai=QUANT_BOWTIE2
        / "{kraken2_db}"
        / "{pathogen}"
        / "{sample_id}.{library_id}.cram.crai",
        reference=REFERENCE / "pathogens" / "{pathogen}.fa.gz",
        fai=REFERENCE / "pathogens" / "{pathogen}.fa.gz.fai",
    output:
        tsv=COVERM
        / "{kraken2_db}"
        / "{pathogen}/contig/{method}/{sample_id}.{library_id}.tsv",
    conda:
        "__environment__.yml"
    log:
        COVERM
        / "{kraken2_db}"
        / "{pathogen}/contig/{method}/{sample_id}.{library_id}.log",
    params:
        method="{method}",
    shell:
        """
        ( samtools view \
            --with-header \
            --reference {input.reference} \
            {input.cram} \
        | coverm contig \
            --bam-files /dev/stdin \
            --methods {params.method} \
            --proper-pairs-only \
            --output-file {output.tsv} \
        ) 2> {log} 1>&2
        """


rule quantify__coverm__contig__aggregate:
    """Aggregate all the nonpareil results into a single table"""
    input:
        get_coverm_contig_tsv_files_for_aggregation,
    output:
        COVERM / "{kraken2_db}" / "coverm_contig_{pathogen}.{method}.tsv",
    log:
        COVERM / "{kraken2_db}" / "coverm_contig_{pathogen}.{method}.log",
    conda:
        "__environment__.yml"
    params:
        input_dir=lambda w: COVERM / w.kraken2_db / w.pathogen / "contig" / w.method,
    shell:
        """
        Rscript --no-init-file workflow/scripts/aggregate_coverm.R \
            --input-folder {params.input_dir} \
            --output-file {output} \
        2> {log} 1>&2
        """


rule quantify__coverm__contig:
    """Run all rules to run coverm contig over all MAG catalogues"""
    input:
        [
            COVERM / kraken2_db / f"coverm_contig_{pathogen}.{method}.tsv"
            for pathogen in PATHOGENS
            for method in params["quantify"]["coverm"]["contig"]["methods"]
            for kraken2_db in KRAKEN2_DBS
        ],


rule quantify__coverm:
    """Run both coverm overall and contig"""
    input:
        rules.quantify__coverm__genome.input,
        rules.quantify__coverm__contig.input,

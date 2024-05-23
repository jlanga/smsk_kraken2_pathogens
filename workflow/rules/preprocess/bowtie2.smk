rule preprocess__bowtie2__cram_to_fastq__:
    input:
        get_input_cram_for_host_mapping,
    output:
        forward_=temp(PRE_BOWTIE2 / "{genome}" / "{sample_id}.{library_id}_1.fq.gz"),
        reverse_=temp(PRE_BOWTIE2 / "{genome}" / "{sample_id}.{library_id}_2.fq.gz"),
    log:
        PRE_BOWTIE2 / "{genome}" / "{sample_id}.{library_id}.cram_to_fastq.log",
    conda:
        "__environment__.yml"
    shell:
        """
        rm -rf {output.forward_}.collate

        ( samtools view \
            -f 12 \
            -u \
            --threads {threads} \
            {input} \
        | samtools collate \
            -O \
            -u \
            -T {output.forward_}.collate \
            --threads {threads} \
            - \
        | samtools fastq \
            -1 {output.forward_} \
            -2 {output.reverse_} \
            --threads {threads} \
            -c 0 \
            /dev/stdin \
        ) 2> {log} 1>&2
        """


# bowtie2 does not like pipes and/or bams


rule preprocess__bowtie2__:
    """Map one library to reference genome using bowtie2

    Output SAM file is piped to samtools sort to generate a CRAM file.
    """
    input:
        # bam=PRE_BOWTIE2 / "{genome}" / "{sample_id}.{library_id}.bam",
        forward_=PRE_BOWTIE2 / "{genome}" / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=PRE_BOWTIE2 / "{genome}" / "{sample_id}.{library_id}_2.fq.gz",
        mock=multiext(
            str(PRE_INDEX) + "/{genome}",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
        reference=REFERENCE / "{genome}.fa.gz",
        fai=REFERENCE / "{genome}.fa.gz.fai",
        gzi=REFERENCE / "{genome}.fa.gz.gzi",
    output:
        cram=PRE_BOWTIE2 / "{genome}" / "{sample_id}.{library_id}.cram",
    log:
        PRE_BOWTIE2 / "{genome}" / "{sample_id}.{library_id}.log",
    params:
        index=lambda w: PRE_INDEX / f"{w.genome}",
        samtools_mem=params["preprocess"]["bowtie2"]["samtools_mem"],
        rg_id=compose_rg_id,
        rg_extra=compose_rg_extra,
    conda:
        "__environment__.yml"
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


rule preprocess__bowtie2:
    """Run bowtie2 on all libraries and generate reports"""
    input:
        [
            PRE_BOWTIE2 / LAST_HOST / f"{sample_id}.{library_id}.cram"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],

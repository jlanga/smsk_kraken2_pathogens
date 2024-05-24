rule kraken2__reads__:
    input:
        PRE_BOWTIE2 / LAST_HOST / "{sample_id}.{library_id}.cram",
    output:
        forward_=K2_READS / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=K2_READS / "{sample_id}.{library_id}_2.fq.gz",
    log:
        K2_READS / "{sample_id}.{library_id}.log",
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


rule kraken2__reads:
    input:
        [
            K2_READS / f"{sample_id}.{library_id}_{end}.fq.gz"
            for sample_id, library_id in SAMPLE_LIBRARY
            for end in [1, 2]
        ],

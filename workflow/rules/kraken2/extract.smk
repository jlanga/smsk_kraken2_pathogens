rule kraken2__extract__:
    input:
        forward_=K2_READS / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=K2_READS / "{sample_id}.{library_id}_2.fq.gz",
        report=K2_CLASSIFY / "{kraken2_db}" / "{sample_id}.{library_id}.report",
        out=K2_CLASSIFY / "{kraken2_db}" / "{sample_id}.{library_id}.out.gz",
    output:
        forward_=K2_EXTRACT / "{kraken2_db}" / "{pathogen}" / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=K2_EXTRACT / "{kraken2_db}" / "{pathogen}" / "{sample_id}.{library_id}_2.fq.gz",
    log:
        K2_EXTRACT / "{kraken2_db}" / "{pathogen}" / "{sample_id}.{library_id}.log",
    conda:
        "__environment__.yml"
    params:
        taxid=get_taxid_from_pathogen,
    shell:
        """
        extract_kraken_reads.py \
            --taxid  {params.taxid} \
            --report  {input.report} \
            --include-children \
            --fastq-output \
            -k  <(gzip -dc {input.out}) \
            -s1 {input.forward_} \
            -s2 {input.reverse_} \
            --output  >(gzip > {output.forward_}) \
            --output2 >(gzip > {output.reverse_}) \
        2> {log} 1>&2
        """


rule kraken2__extract:
    input:
        [
            K2_EXTRACT / kraken2_db / pathogen / f"{sample_id}.{library_id}_{end}.fq.gz"
            for kraken2_db in KRAKEN2_DBS
            for pathogen in PATHOGENS
            for sample_id, library_id in SAMPLE_LIBRARY
            for end in [1, 2]
        ]

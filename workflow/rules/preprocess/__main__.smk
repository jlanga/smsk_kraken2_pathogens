include: "__functions__.smk"
include: "index.smk"
include: "bowtie2.smk"
include: "fastp.smk"
include: "samtools.smk"


rule preprocess:
    input:
        rules.preprocess__fastp.input,
        rules.preprocess__bowtie2.input,

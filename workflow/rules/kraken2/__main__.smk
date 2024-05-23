include: "__functions__.smk"
include: "reads.smk"
include: "classify.smk"
include: "extract.smk"


rule kraken2:
    input:
        # rules.kraken2__reads.input,
        # rules.kraken2__classify.input
        rules.kraken2__extract.input,

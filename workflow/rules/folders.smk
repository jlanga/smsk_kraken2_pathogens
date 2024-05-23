READS = Path("results/reads/")

REFERENCE = Path("results/reference/")

PRE = Path("results/preprocess/")
FASTP = PRE / "fastp"
PRE_INDEX = PRE / "index"
PRE_BOWTIE2 = PRE / "bowtie2"

K2 = Path("results/kraken2")
K2_READS = K2 / "reads"
K2_CLASSIFY = K2 / "classify"
K2_EXTRACT = K2 / "extract"


QUANT = Path("results/quantify/")
QUANT_INDEX = QUANT / "index"
QUANT_BOWTIE2 = QUANT / "bowtie2"
COVERM = QUANT / "coverm"

REPORT = Path("reports")
REPORT_STEP = REPORT / "by_step"
REPORT_LIBRARY = REPORT / "by_library"

# smsk: A Snakemake skeleton to jumpstart projects

[![Build Status](https://travis-ci.org/jlanga/smsk.svg?branch=master)](https://travis-ci.org/jlanga/smsk)

## 1. Description

This is a small skeleton to create Snakemake workflows. [Snakemake](https://bitbucket.org/snakemake/snakemake/wiki/Home) "is a workflow management system that aims to reduce the complexity of creating workflows by providing a fast and comfortable execution environment, together with a clean and modern specification language in python style."

The idea is to create a workflow with of snakefiles, resolve dependencies with `conda`, `pip`, tarballs, and if there is no other option, `docker`.

## 2. First steps

Follow the contents of the `.travis.yml` file:

1. Install (ana|mini)conda

    - [Anaconda](https://www.continuum.io/downloads)

    - [miniconda](http://conda.pydata.org/miniconda.html)

2. Installation

    ```sh
    git clone https://github.com/jlanga/smsk.git smsk
    cd smsk
    conda --use-conda --create-envs-only
    ```

3. Execute the test pipeline:

    ```sh
    snakemake --use-conda -j
    ```

4. Modify the following files:

    - `samples.yml` with info on your samples,
    - `cluster.yml` (optional) with run time and memory of the intensive tasks.

5. Run the pipeline with your data

    ```sh
    snakemake --use-conda -j
    ```

6. (Optional) Run the pipeline inside a Docker container:

    ```sh
    bash src/run_docker.sh
    ```

## 3. File organization

The hierarchy of the folder is the one described in [Good enough practices in scientific computing](https://swcarpentry.github.io/good-enough-practices-in-scientific-computing/):

```none
smsk
├── cluster.yml: info on memory and running time of certain jobs.
├── data: raw data or links to backup data.
├── doc: documentation.
├── reports: reports generated by this example.
├── README.md
├── results: processed data.
├── Snakefile: driver script of the project. Mostly links to src/snakefiles.
└── src: project's source code, snakefiles tarballs, scripts for the lazy.
```

## 4. Writting workflow considerations

- The workflow should be written in the main `Snakefile` and all the subworkflows in `src/snakefiles`.

- Split into different snakefiles as much as possible. This way code supervision is more bearable
and you can recycle them for other projects.

- Start each rule name with the name of the subworkflow (`map`): `map_bowtie`, `map_sort`,
`map_index`.

- Use a Snakefile to store all the folder names instead of typing them explicitelly
(`bin/snakefiles/folders.py`), and using variables with the convention `SUBWORKFLOW_NAME`:
`map_bwa_sample`, `map_sort_sample`, etc.

- End a workflow with a checkpoint rule: a rule that takes as input the result of the workflow
(`map`). Use the subworkflow name as a folder name to store its results: `map` results go into
`results/map/`.

- Log everything. Store it next to the results: `rule/name_wildcards.log`. Store also benchmarks.
Consider even creating a subfolder if the total number of files is too high.

- End it also with a clean rule that deletes everything of the workflow (`clean_map`).

- Use the `bin/snakefiles/raw` to get/link your raw data, databases, etcetera. You should be careful
 when cleaning this folder.

- Configuration for software, samples, etcetera, should be written in config files (instead of
hardcoding them somewhere in a 1000 line script). Command line software usually comes with mandatory
parameters and optional ones. Ideally, write the mandatory ones in each snakefile and the optional
in the config files.

- In the same way that in Bioconductor datasets are split into three different tables (experimental,
sample and feature data), we should do the same:

  - `sample.yml`: information about your samples: library names, paths to fastq files, type of
    sequencing, ...

  - `features.yml`: information about the reference genome, transcriptome, annotation, ...

  - `params.yml`: non-default parameters of each one of the programs we are using: number of maximum
    threads, compression levels of `samtools`, quality thresholds for trimmomatic, ...

  - `cluster.yml`: information about how to execute in the cluster environment each of the rules:
    how many threads and how much memory.

- `shell.prefix("set -euo pipefail;")` in the first line of the Snakefile makes the entire workflow
to stop in case of even a warning or a exit error different of 0. Maybe not necessary anymore
(2016/12/13).

- If compressing, use `pigz`, `pbzip2` or `pxz` instead of `gzip`. Get them from `conda`.

- Install as many possible packages from `conda` and `pip` instead of using `apt`/`apt-get`:
software is more recent, and you don't have to unzip tarballs or rely on your sysadmin. This way
your workflow is more reproducible. The problem I see with `brew` is that you cannot specify an
exact version.

- To install software from tarballs, download them into `src/` and copy binaries to `bin/` (and
write the steps in `bin/install/from_tarball.sh`):

    ```sh
    # Binaries are already compiled
    wget \
        --continue \
        --output-document src/bin1.tar.gz \
        http://bin1.com/bin1.tar.gz
    tar xvf src/bin1.tar.gz
    cp src/bin1/bin1 bin/ # or link

    # Tarball contains the source
    wget \
        --continue \
        --output-document src/bin2.tar.gz \
        http://bin2.com/bin2.tar.gz
    tar xvf src/bin2.tar.gz
    pushd src/bin2/
    make -j
    cp build/bin2 ../../bin/
    ```

- Use as much as possible `temp()` and `protected()` so you save space and also protect yourself
from deleting everything.

- Pipe and compress as much as possible. Make use of the [process substitution](http://vincebuffalo.org/blog/2013/08/08/using-names-pipes-and-process-substitution-in-bioinformatics.html)
feature in `bash`: `cmd <(gzip -dc fa.gz)` and `cmd >(gzip -9 > file.gz)`. The problem is that it is
 hard to estimate the CPU usage of each step of the workflow.

- End each subworkflow with a report for your own sanity. Or write the rules in
`bin/snakefiles/report`. Make use of all the tools that multiqc supports.

- Use in command line applications long flags (`wget --continue $URL`): this way it is more
readable. The computer does not care and is not going to work slower.

- If software installation is too complex, consider pulling a docker image.




## Bibliography

- [A Quick Guide to Organizing Computational Biology Projects](http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1000424)

- [Snakemake—a scalable bioinformatics workflow engine](http://bioinformatics.oxfordjournals.org/content/28/19/2520)

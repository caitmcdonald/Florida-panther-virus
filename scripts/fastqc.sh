#!/bin/bash

#SBATCH --mem 5GB
#SBATCH --time=04:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=cait.mcdonald@colostate.edu
#SBATCH --output=output-%j
#SBATCH --error=error-%j


## load envs
source ~/.bashrc
conda activate qctrim

## run fastqc
# fastqc -t 19 data/samples/*.fastq.gz -o results/fastqc/raw
fastqc -t 19 data/*fc.fastq.gz -o results/fastqc/trimmed #trimmed files

## run multiqc
# multiqc results/fastqc/raw -o results/multiqc/raw
multiqc results/fastqc/trimmed -o results/multiqc/trimmed

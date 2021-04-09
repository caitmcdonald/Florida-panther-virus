#!/bin/bash

#CHANGE SLURM OPTIONS:
#SBATCH --mem 70GB
#SBATCH --cpus-per-task=22
#SBATCH --time=3:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=cait.mcdonald@colostate.edu
#SBATCH --output=output-%j
#SBATCH --error=error-%j

#LOAD CONDA ENV
source ~/.bashrc
conda activate enFeLV

echo starting....

## ADD BOWTIE BUILD STEP TO GENERATE INDEXES
# for fa in fasta_files/*.fasta; do
#     bowtie2-build $fa ${fa%%.*};
# done
#
# mv fasta_files/*.bt2 data/

#get a list of all the .fastq files without numbers
#ie for each pair of files: <filename>_1.fastq and <filename>_2.fastq, we want the entry filename in our list
#we dont want duplicates

cd data/ #ADD CD SO IN RIGHT DIRECTORY

uniqlist=$( ls *.fastq.gz | cut -d'_' -f 1-3 | uniq) #CHANGE TO COMPRESSED FORMAT, RETAIN 1ST THROUGH 3RD FIELDS

#for each entry in the list we constructed above
for currentFileName in $uniqlist; do
    #Print the current file name to the console
    echo Current FileName:  $currentFileName;

    #Concatenate the current file name with certain strings
    #ie if $currentFileName=bab, the command $(echo $currentFileName)$(echo _Some_Extra_Stuff) will produce: bab_Some_Extra_Stuff
    #we store each new filename in a variable
    fileName_1_f=$(echo $currentFileName)$(echo _R1_001_f.fastq.gz);
    fileName_2_f=$(echo $currentFileName)$(echo _R2_001_f.fastq.gz);
    fileName_1_fc=$(echo $currentFileName)$(echo _R1_001_fc.fastq.gz);
    fileName_2_fc=$(echo $currentFileName)$(echo _R2_001_fc.fastq.gz);

    #echo commands to the screen using our variables
    ## CHANGE ABSOLUTE PATHS
    cutadapt --cores=20 -q 20 -o $fileName_1_f $(echo $currentFileName)_R1_001.fastq.gz; #CHANGE TO MATCH FILE ENDINGS, MULTITHREAD
    cutadapt --cores=20 -q 20 -o $fileName_2_f $(echo $currentFileName)_R2_001.fastq.gz; #CHANGE TO MATCH FILE ENDINGS, MULTITHREAD
    cutadapt --cores=20 -a AGATCGGAAGAGCGT -a GATCGGAAGAGCACA -o $fileName_1_fc $fileName_1_f; #WAS MISSING SPACE AFTER -A
    cutadapt --cores=20 -a AGATCGGAAGAGCGT -a GATCGGAAGAGCACA -o $fileName_2_fc $fileName_2_f; ##WAS MISSING SPACE AFTER -A

    ## CHANGE ABSOLUTE PATHS
    bowtie2 -x enFeLV_full -q -1 $fileName_1_fc -2 $fileName_2_fc --no-unal --local --score-min C,120,1 --threads 20 -S $(echo $currentFileName)_mapped_to_enFeLV_full.sam &> $(echo $currentFileName)_enFeLV_full_Output.txt ;
    bowtie2 -x enFeLV_env -q -1 $fileName_1_fc -2 $fileName_2_fc --no-unal --local --score-min C,120,1 --threads 20 -S $(echo $currentFileName)_mapped_to_enFeLV_env.sam &> $(echo $currentFileName)_enFeLV_env_Output.txt ;
    bowtie2 -x enFeLV_gag -q -1 $fileName_1_fc -2 $fileName_2_fc --no-unal --local --score-min C,120,1 --threads 20 -S $(echo $currentFileName)_mapped_to_enFeLV_gag.sam &> $(echo $currentFileName)_enFeLV_gag_Output.txt ;
    bowtie2 -x enFeLV_LTR -q -1 $fileName_1_fc -2 $fileName_2_fc --no-unal --local --score-min C,120,1 --threads 20 -S $(echo $currentFileName)_mapped_to_enFeLV_LTR.sam &> $(echo $currentFileName)_enFeLV_LTR_Output.txt ;
    bowtie2 -x enFeLV_pol -q -1 $fileName_1_fc -2 $fileName_2_fc --no-unal --local --score-min C,120,1 --threads 20 -S $(echo $currentFileName)_mapped_to_enFeLV_pol.sam &> $(echo $currentFileName)_enFeLV_pol_Output.txt ;
done

#!/bin/bash

#CHANGE SLURM OPTIONS:
#SBATCH --mem 5GB
#SBATCH --time=02:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=cait.mcdonald@colostate.edu
#SBATCH --output=output-%j
#SBATCH --error=error-%j

#LOAD CONDA ENV
conda activate [env_name--need cutadapt and bowtie2]

echo starting....

## ADD BOWTIE BUILD STEP TO GENERATE INDEXES
cd data
for fa in ../fasta_files/*.fasta; do
    bowtie2-build $fa ${fa%%.*}
done

#get a list of all the .fastq files without numbers
#ie for each pair of files: <filename>_1.fastq and <filename>_2.fastq, we want the entry filename in our list
#we dont want duplicates
uniqlist=$( ls *.fastq.gz | cut -d'_' -f 1 | uniq) #CHANGE TO COMPRESSED FORMAT

#for each entry in the list we constructed above
for currentFileName in $uniqlist; do
    #Print the current file name to the console
    echo Current FileName:  $currentFileName;

    #Concatenate the current file name with certain strings
    #ie if $currentFileName=bab, the command $(echo $currentFileName)$(echo _Some_Extra_Stuff) will produce: bab_Some_Extra_Stuff
    #we store each new filename in a variable
    fileName_1_f=$(echo $currentFileName)$(echo _1_f.fastq);
    fileName_2_f=$(echo $currentFileName)$(echo _2_f.fastq);
    fileName_1_fc=$(echo $currentFileName)$(echo _1_fc.fastq);
    fileName_2_fc=$(echo $currentFileName)$(echo _2_fc.fastq);

    #echo commands to the screen using our variables
    ## CHANGE ABSOLUTE PATHS
    cutadapt -q 20 -o $fileName_1_f $(echo $currentFileName)_1.fastq;
    cutadapt -q 20 -o $fileName_2_f $(echo $currentFileName)_2.fastq;
    cutadapt -aAGATCGGAAGAGCGT -aGATCGGAAGAGCACA -o $fileName_1_fc $fileName_1_f; #missing a space after -a???
    cutadapt -aAGATCGGAAGAGCGT -aGATCGGAAGAGCACA -o $fileName_2_fc $fileName_2_f; #missing a space after -a???

    ## CHANGE ABSOLUTE PATHS
    bowtie2 -x FeLV_enFeLV_index -q -1 $fileName_1_fc -2 $fileName_2_fc --no-unal --local --score-min C,120,1 --threads 4 -S $(echo $currentFileName)_mapped_to_enFeLVand61E.sam &> $(echo $currentFileName)enFeLVOutput.txt ;
done

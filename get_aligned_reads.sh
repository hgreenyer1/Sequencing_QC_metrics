#!/bin/bash

bam_suf=$1
out_file=$2

#loop through bam files with given suffix

echo -e "sample\traw_reads\tmapped_reads" >> "$out_file"

for bam_f in ./*$bam_suf
do
        total_reads=$(samtools view -c $bam_f)
        mapped_reads=$(samtools view -F 4 -c $bam_f)

        echo -e "$sample\t$total_reads\t$mapped_reads" >> "$out_file"
done

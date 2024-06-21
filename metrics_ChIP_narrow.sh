#!/bin/bash 

bam_suf=$1
out_file=$2

#loop through bam files with given suffix

echo -e "sample\tmapped_reads\tpeaks_called\tfrip_score" >> "$out_file"

for bam_f in ./*$bam_suf
do
        total_reads=$(samtools view -c $bam_f)
        mapped_reads=$(samtools view -F 4 -c $bam_f)

        sample="$(basename -- ${bam_f/'.Aligned.sortedByCoord.out.bam'/''})"
        peak_f="./$(basename -- ${bed_f/'.Aligned.sortedByCoord.out.bam'/'.Aligned.sortedByCoord.out_macs2_peaks.narrowPeak'})"
	
	cut -f 1,2,3,4,5,6,7,8,9 narrowPeak_file.narrowPeak > $peak_f.tmp.bed
	
        peak_counts=$(wc -l < "$peak_f")

        overlap_reads=$(bedtools intersect -u -a "$bam_f" -b "$peak_bed" | wc -l)
        frip_score=$(echo "scale=2; $overlap_reads * 100 / $total_reads" | bc)
        echo $peak_counts

        echo -e "$sample\t$mapped_reads\t$peak_counts\t$frip_score" >> "$out_file"
	rm $peak_f.tmp.bed
done

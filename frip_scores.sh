#!/bin/bash 
#script to generate alignment and peak call metrics for ChIP or ATAC  

bam_suf=$1
out_file=$2

#loop through bam files with given suffix

echo -e "sample\tmapped_reads\tpeaks_called\tfrip_score" >> "$out_file"

for bam_f in ./*$bam_suf
do
	total_reads=$(samtools view -c $bam_f)
	mapped_reads=$(samtools view -F 4 -c $bam_f)
	
	sample="$(basename -- ${bam_f/'.Aligned.sortedByCoord.out.bam'/''})"
	bed_f="./$(basename -- ${bam_f/'.Aligned.sortedByCoord.out.bam'/'.Aligned.sortedByCoord.out_macs2_summits.bed'})"
	peak_f="./$(basename -- ${bed_f/'.Aligned.sortedByCoord.out.bam'/'.Aligned.sortedByCoord.out_macs2_peaks.narrowPeak'})"

	peak_counts=$(wc -l < "$peak_f")
	
	overlap_reads=$(bedtools intersect -u -a "$bam_f" -b "$bed_f" | wc -l)
	frip_score=$(echo "scale=2; $overlap_reads * 100 / $total_reads" | bc)
	echo $peak_counts
	
	echo -e "$sample\t$mapped_reads\t$peak_counts\t$frip_score" >> "$out_file"
done


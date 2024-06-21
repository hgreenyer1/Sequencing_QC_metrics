#!/bin/bash

#calculate alignment and peak calling

out_file=$1

#loop through bam files with given suffix

echo -e "sample\traw_reads\tpercent_mito\tfiltered_reads\tpeaks_called\tfrip_score" >> "$out_file"

for r_bam in ./RAW_BAMS/*_001_sorted.bam
do
	#get files

        sample="$(basename -- ${r_bam/'_R1_001_sorted.bam'/''})"
        f_bam="./FILTERED_BAMS/$(basename -- ${r_bam/'_sorted.bam'/'_sorted.filt.nodup.bam'})"
	r_sam="./RAW_BAMS/$(basename -- ${r_bam/'_sorted.bam'/'.sam'})"
        peak_f="./PEAKS/$(basename -- ${r_bam/'_sorted.bam'/'_sorted.filt.nodup_peaks.narrowPeak'})"

	#alignment metrics 

        total_reads=$(samtools view -c $r_bam)
        filt_reads=$(samtools view -F 4 -c $f_bam)

	s_reads=$(grep -c 'chr*' $r_sam)
	m_reads=$(grep -c 'chrM' $r_sam)
	p_mito=$(echo "scale=2; $m_reads * 100 / $s_reads" | bc)

        cut -f 1,2,3,4,5,6,7,8,9 ${peak_f} > ${peak_f}.tmp.bed
	
	#peak calling metrics

        peak_counts=$(wc -l < "$peak_f")

        overlap_reads=$(bedtools intersect -u -a "$f_bam" -b "${peak_f}.tmp.bed" | wc -l)
        frip_score=$(echo "scale=2; $overlap_reads * 100 / $filt_reads" | bc)
        echo $peak_counts

        echo -e "$sample\t$total_reads\t$p_mito\t$filt_reads\t$peak_counts\t$frip_score" >> "$out_file"
        rm $peak_f.tmp.bed
done

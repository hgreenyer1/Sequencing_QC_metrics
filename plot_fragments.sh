#!/bin/bash

for BAM in "$@"
do 
   samtools view $BAM | awk '$9>0' | cut -f 9 | sort | uniq -c | sort -b -k2,2n | sed -e 's/^[ \t]*//' > $BAM"_fragment_length_count.txt"
done

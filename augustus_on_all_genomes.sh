#!/bin/bash
for file in genomes_raw/*.fna; do
    augustus --species=aspergillus_nidulans "$file" --gff3=on --codingseq=on --stopCodonExcludedFromCDS=off > "${file%.fna}.gff"
done
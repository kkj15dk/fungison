#!/bin/bash
GENOMES_DIR=genomes_raw

echo "Assuming DNA genomes, renaming .fasta to .fna"

# Rename .fasta to .fna
for GENOME in "$GENOMES_DIR"/*.fasta; do
    mv -- "$GENOME" "${GENOME%.fasta}.fna"
done

for GENOME in $GENOMES_DIR*.fna; do
    # Test if .gff already exists for the file
    if test -f "${GENOME%.fna}.gff"; then
        echo "${GENOME%.fna}.gff already exists, continuing with next genome"
        continue
    fi
    
    augustus --species=aspergillus_nidulans "$GENOME" --gff3=on --codingseq=on --stopCodonExcludedFromCDS=off > "${file%.fna}.gff"
    echo "augustus finished on $GENOME"
done
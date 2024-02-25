#!/bin/bash
GENOMES_DIR=genomes_data

echo "Assuming DNA genomes, renaming .fasta to .fna"

for GENOME in $GENOMES_DIR/*.fna; do
    # Test if .gff already exists for the file
    FILENAME=$(basename -- "$GENOME" .fna)
    if test -f "${GENOME%.fna}.gff"; then
        echo "${GENOME%.fna}.gff already exists, continuing with next genome"
        continue
    fi
    echo "using augustus on $GENOME ..."
    augustus --species=aspergillus_nidulans "$GENOME" --gff3=on --stopCodonExcludedFromCDS=off > "${GENOME%.fna}.gff"
    echo "augustus finished $GENOME"
done
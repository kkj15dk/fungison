#!/bin/bash
GENOMES_DIR=genomes_data

echo "Assuming DNA genomes, renaming .fasta to .fna"

# Rename .fasta to .fna
for GENOME in "$GENOMES_DIR"/*.fasta; do
    mv -- "$GENOME" "${GENOME%.fasta}.fna"
done
#!/bin/bash
GENOMES_DIR=genomes_data
ANTISMASH_OUTPUT_DIR=antismash_output

for GENOME in "$GENOMES_DIR"/*.fna; do

    FILENAME=$(basename -- "$GENOME" .fna)

    # Test if the genome has already been converted (If there is a genome.txt file)
    if test -f "${GENOME%.fna}.txt"; then
        echo "${GENOME%.fna}.txt already exist, continuing with next genome"
        continue
    fi

    # Test if we have the antismash input
    if !(test -f "$ANTISMASH_OUTPUT_DIR/$FILENAME/$FILENAME.gbk"); then
        echo "antismash output for $FILENAME doesn't exists, continuing with next genome"
        continue
    fi

    # Test if we have the .gff input
    if !(test -f "${GENOME%.fna}.gff"); then
        echo "${GENOME%.fna}.gff doesn't exist, continuing with next genome"
        continue
    fi

    echo "converting $GENOME to fungison format"
    perl GFF_GBK_to_FUNGISON_3.pl "${GENOME%.fna}.gff" "$ANTISMASH_OUTPUT_DIR/$FILENAME/$FILENAME.gbk"
    echo "conversion for $GENOME done"
done
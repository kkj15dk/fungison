#!/bin/bash
GENOMES_DIR=genomes_data
ANTISMASH_OUTPUT_DIR=antismash_output

for GENOME in "$GENOMES_DIR"/*.fna; do
    # Test if we have the output already
    FILENAME=$(basename -- "$GENOME" .fna)
    if test -f "$ANTISMASH_OUTPUT_DIR/$FILENAME/$FILENAME.gbk"; then
        echo "antismash output for $FILENAME already exists, continuing with next genome"
        continue
    fi

    echo "running antismash on $GENOME"
    run_antismash "$GENOME" "$ANTISMASH_OUTPUT_DIR" --genefinding-gff3 /input/"$FILENAME".gff --taxon fungi --fullhmmer --cc-mibig --cb-knownclusters
    echo "antismash finished on $GENOME\n"
done
#!/bin/bash
ANTISMASH_OUTPUT_DIR=antismash_output

# Using 1 CPUs, meaning that i can run 48 parallel processes at once

# Input: filename file.fna
run_antismash "$2" "$ANTISMASH_OUTPUT_DIR" --genefinding-gff3 /input/"$1".gff --cpus 1 --taxon fungi --fullhmmer --cc-mibig --cb-knownclusters
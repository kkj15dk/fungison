#!/bin/bash
ANTISMASH_OUTPUT_DIR=antismash_output

# Using 8 CPUs at once, meaning that i can run 6 parallel processes at once

# Input: filename file.fna
run_antismash "$2" "$ANTISMASH_OUTPUT_DIR" --genefinding-gff3 /input/"$1".gff --cpus 8 --taxon fungi --fullhmmer --cc-mibig --cb-knownclusters
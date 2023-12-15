#!/bin/bash
# Input: filename file.gff

ANTISMASH_OUTPUT_DIR=antismash_output

perl GFF_GBK_to_FUNGISON_3.pl "$2" "$ANTISMASH_OUTPUT_DIR/$1/$1.gbk"
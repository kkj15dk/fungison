#!/bin/bash
for file in jgi_genomes/*.fasta; do
    mv -- "$file" "${file%.fasta}.fna"
done
#!/bin/bash
for file in jgi_genomes/*.fna; do
    augustus --species=aspergillus_nidulans "$file" --gff3=on --stopCodonExcludedFromCDS=off > "${file%.fna}.gff"
done
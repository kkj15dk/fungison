#!/bin/bash

# Input: file.fna
augustus --species=aspergillus_nidulans "$1" --gff3=on --stopCodonExcludedFromCDS=off > "${1%.fna}.gff"
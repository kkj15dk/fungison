#!/bin/bash

# This script takes a lot of time to run. It will run in the background
nohup ./augustus_on_all_genomes.sh > "nohup_augustus.out" && ./antismash_on_all_genomes.sh > "nohup_antismash.out" && ./convert_gff_gbk_to_fungison.sh > "nohup_conversion_to_fungison.out" &

#!/bin/bash

# Specify the number of parallel processes, otherwise 6 processes
while getopts "t:" flag;
do
  case "$flag" in 
    t) num_processes=${OPTARG};;
    *) num_processes=6;;
  esac
done

# Specify the folder containing input files
GENOMES_DIR="genomes_data"

# Make logs directory if it doesn't exist
if !(test -d logs); then
    mkdir logs
fi

# Create a processing file if it doesn't exist
processing_file="logs/processing.txt"
touch "$processing_file"

# Create a marker file if it doesn't exist
processed_file="logs/processed_files.txt"
touch "$processed_file"

# Create a lgo file if it doesn't exist
log_file="logs/processing_log.txt"
touch "$log_file"

# Get a list of input files
input_files=("$GENOMES_DIR"/*.fna)

# Run the master script in parallel
parallel -j "$num_processes" ./parallel_processing_master.sh ::: "${input_files[@]}"

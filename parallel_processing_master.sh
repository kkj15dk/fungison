#!/bin/bash

GENOMES_DIR=genomes_data
ANTISMASH_OUTPUT_DIR=antismash_output

log_file="logs/processing_log.txt"
processing_files="logs/processing.txt"
processed_files="logs/processed_files.txt"

error_exit() {
    echo "Error: $1" > "$log_file"
    exit 1
}

augustus() {
    # Input: file.fna
    input_file_fna=$1

    # Mark file as processing
    echo "$input_file_fna" >> "$processing_files"

    # Record start time
    start_time=$(date +%s)

    # Test if .gff already exists for the file
    if test -f "${input_file_fna%.fna}.gff"; then
        echo "$(date) - Skipping augustus. ${input_file_fna%.fna}.gff already exists" >> "$log_file"
        echo "$input_file_fna" >> "$processed_files"
        return
    fi

    # Log initiation of processing
    echo "$(date) - Augustus started for $FILENAME" >> "$log_file"

    # Execute augustus
    ./augustus.sh "$input_file_fna" || error_exit "$(date) - Augustus failed for $FILENAME"

    # Record end time
    end_time=$(date +%s)
    elapsed_time=$((end_time - start_time))

    # Log completion of processing
    echo "$(date) - Augustus completed for $FILENAME in $elapsed_time seconds" >> "$log_file"

    # Mark file as processed
    echo "$input_file_fna" >> "$processed_files"
}

antismash() {
    # Input: file.gff file.fna
    # Assumes that .fna and .gff is in the same folder (which is needed for antismash running in docker)
    input_file_gff=$1
    input_file_fna=$2

    # Mark file as processing
    echo "$input_file_gff" >> "$processing_files"

    # Record start time
    start_time=$(date +%s)

    # Test if we have the output .gbk already
    FILENAME=$(basename -- "$input_file_fna" .fna)
    if test -f "$ANTISMASH_OUTPUT_DIR/$FILENAME/$FILENAME.gbk"; then
        echo "$(date) - Skipping antismash. Antismash output for $FILENAME already exists" >> "$log_file"
        echo "$input_file_gff" >> "$processed_files"
        return
    fi

    # Log initiation of processing
    echo "$(date) - Antismash started for $FILENAME." >> "$log_file"

    # Execute antismash
    ./antismash.sh "$FILENAME" "$input_file_fna" || error_exit "$(date) - Antismash failed for $FILENAME"

    # Record end time
    end_time=$(date +%s)
    elapsed_time=$((end_time - start_time))

    # Log completion of processing
    echo "$(date) - Antismash completed for $FILENAME in $elapsed_time seconds." >> "$log_file"

    # Mark file as processed
    echo "$input_file_gff" >> "$processed_files"
}

convert_to_fungison() {
    # Input: file.gbk file.gff
    input_file_gbk=$1
    input_file_gff=$2

    # Mark file as processing
    echo "$input_file_gbk" >> "$processing_files"

    # Record start time
    start_time=$(date +%s)

    # Test if the genome has already been converted (If there is a .txt file)
    if test -f "${input_file_gff%.gff}.txt"; then
        echo "$(date) - Skipping conversion to fungison. ${input_file_gff%.gff}.txt already exists" >> "$log_file"
        echo "$input_file_gbk" >> "$processed_files"
        return
    fi

    # Log initiation of processing
    echo "$(date) - Conversion to fungison format started for $FILENAME." >> "$log_file"

    # Execute conversion to fungison
    ./convert_to_fungison.sh "$input_file_gbk" "$input_file_gff" || error_exit "$(date) - Coversion failed for $FILENAME"

    # Record end time
    end_time=$(date +%s)
    elapsed_time=$((end_time - start_time))

    # Log completion of processing
    echo "$(date) - Conversion to fungison format completed for $FILENAME in $elapsed_time seconds." >> "$log_file"

    # Mark file as processed
    echo "$input_file_gbk" >> "$processed_files"
}


# Example usage:
input_file_fna=$1
FILENAME=$(basename -- "$input_file_fna" .fna)

# Augustus
# Check if the file has already been processed, is being processed, or if the output is already there.
if grep -q "$input_file_fna" "$processed_files"; then
    echo "File $input_file_fna has already been processed by augustus. Skipping."
elif grep -q "$input_file_fna" "$processing_files"; then
    echo "File $input_file_fna is being processed by augustus. Skipping."
    exit
else
    augustus "$input_file_fna"
fi
input_file_gff="${input_file_fna%.fna}.gff"

# Antismash
# Check if the file has already been processed, is being processed, or if the output is already there.
if grep -q "$input_file_gff" "$processed_files"; then
    echo "File $input_file_gff has already been processed by antismash. Skipping."
elif grep -q "$input_file_gff" "$processing_files"; then
    echo "File $input_file_gff is being processed by antismash. Skipping."
    exit
else
    antismash "$input_file_gff" "$input_file_fna"
fi
input_file_gbk="$ANTISMASH_OUTPUT_DIR/$FILENAME/$FILENAME.gbk"

# Conversion to fungison
# Check if the file has already been processed, is being processed, or if the output is already there.
if grep -q "$input_file_gbk" "$processed_files"; then
    echo "File $input_file_gbk has already been converted to fungison. Skipping."
elif grep -q "$input_file_gbk" "$processing_files"; then
    echo "File $input_file_gbk is being converted to fungison. Skipping."
    exit
else
    convert_to_fungison "$input_file_gbk" "$input_file_gff"
fi

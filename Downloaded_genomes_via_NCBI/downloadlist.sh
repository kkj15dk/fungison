#!/bin/bash

while read -r line      # read a line from file.
do
  echo \'$line\'
  bash download_fungal_genomes.sh "$line"            # pass a line to the script
done < strains.txt
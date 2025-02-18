#!/bin/bash

# Check if a command-line argument (file name) is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

# The input file is provided as the first command-line argument
input_file="$1"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "File $input_file does not exist."
  exit 1
fi

# Read the file line by line
while IFS= read -r param; do
  # Skip empty lines
  if [ -z "$param" ]; then
    continue
  fi
  
  # Replace with the command you want to execute
  command "$param"
  # Example: echo "Processing $param"
done < "$input_file"


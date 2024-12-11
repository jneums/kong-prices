#!/bin/bash

# Directory to search for .png files
DIRECTORY="src/fe/assets/tokens"

# Iterate over each .png file in the directory
for file in "$DIRECTORY"/*.png; do
  if [ -f "$file" ]; then
    # Get the base name of the file (without extension)
    base_name=$(basename "$file" .png)
    
    # Define the output file name
    output_file="${DIRECTORY}/${base_name}_48x48.png"
    
    # Use ffmpeg to resize the image to 48x48
    ffmpeg -i "$file" -vf "scale=48:48" "$output_file"
    
    echo "Resized $file to $output_file"
  fi
done
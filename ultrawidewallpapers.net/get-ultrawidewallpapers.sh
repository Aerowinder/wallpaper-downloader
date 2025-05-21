#!/bin/bash

# Base URL and output directory
BASE_URL="https://www.ultrawidewallpapers.net/wallpapers/329/highres"
OUTPUT_DIR="/mnt/private/Wallpaper/ultrawidewallpapers.net/7680x2160/"
STATE_FILE="./.last_download" # File to track last attempted download
MIN_SIZE=102400 # Minimum file size in bytes (100 KB)

# Read starting point from state file or default to 1
if [[ -f "$STATE_FILE" ]]; then
    START=$(( $(<"$STATE_FILE") + 1 ))
    echo "Resuming from ID: $START"
else
    START=1
    echo "Starting fresh from ID: $START"
fi

# Ensure output directory exists
if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "Error: Output directory does not exist: $OUTPUT_DIR"
    exit 1
fi

# Loop from last known good point to 5000
for ((i=START; i<=9999; i++)); do
    FILE_NAME="aishot-$i.jpg"
    URL="$BASE_URL/$FILE_NAME"
    OUTPUT_PATH="$OUTPUT_DIR/$FILE_NAME"

    echo "Checking $URL..."

    if curl -f -s -S "$URL" -o "$OUTPUT_PATH"; then
        FILE_SIZE=$(stat -c %s "$OUTPUT_PATH")
        if [[ "$FILE_SIZE" -gt "$MIN_SIZE" ]]; then
            echo "Downloaded: $FILE_NAME ($FILE_SIZE bytes)"
            echo "$i" > "$STATE_FILE" # Save progress after each successful download
        else
            echo "Warning: $FILE_NAME is too small ($FILE_SIZE bytes), deleting..."
            rm -f "$OUTPUT_PATH"
            echo "Exiting due to undersized file."
            exit 1
        fi
    else
        echo "Skipped: $FILE_NAME (not found)"
        echo "Exiting due to download failure."
        exit 1
    fi
done

#Changelog
#2025-05-20 - AS - v1, First release.

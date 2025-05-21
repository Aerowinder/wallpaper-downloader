#!/bin/bash

# Base URL and minimum file size allowed
BASE_URL="https://www.ultrawidewallpapers.net/wallpapers/329/highres"
MIN_SIZE=102400 # Minimum file size in bytes (100 KB)

usage() {
    echo
    echo "USAGE:        $0 -o OUTPUT_DIR"
    echo "EXAMPLE:      $0 -o /home/adam/wallpaper"
    echo
    echo "OUTPUT_DIR:   Must be writable; script will create"
    echo
    exit 1
}

# Parse options
while getopts "o:s:" opt; do
    case $opt in
        o) OUTPUT_DIR="$OPTARG" ;;
        *) usage ;;
    esac
done
STATE_FILE="$OUTPUT_DIR/.state" # File to track last attempted download

# Ensure output directory exists
mkdir -p $OUTPUT_DIR
if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "Error: Output directory does not exist: $OUTPUT_DIR"
    usage
fi

# Read starting point from state file or default to 1
if [[ -f "$STATE_FILE" ]]; then
    START=$(( $(<"$STATE_FILE") + 1 ))
    echo "Resuming from ID: $START"
else
    START=1
    echo "Starting fresh from ID: $START"
fi

# Loop from last known good point to 9999
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
#2025-05-21 - AS - v1, First release.

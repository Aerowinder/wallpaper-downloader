#!/bin/bash

usage() {
    echo
    echo "USAGE:        $0 -i INPUT_DIR -o OUTPUT_DIR -t IMAGE_TYPE -a CROP_ANCHOR -w CROP_WIDTH -h CROP_HEIGHT"
    echo "EXAMPLE:      $0 -i /home/adam/original -o /home/adam/cropped -t jpg -a center -w 5160 -h 2160"
    echo
    echo "INPUT_DIR:    Must be readable"
    echo "OUTPUT_DIR:   Must be writable; script will create"
    echo
    echo "IMAGE_TYPE:   jpg, jpeg, png, bmp, webp"
    echo
    echo "CROP_ANCHOR:  center, topleft, topcenter, topright, bottomleft, bottomcenter, bottomright, middleleft, middleright"
    echo "CROP_WIDTH:   Must be integer"
    echo "CROP_HEIGHT:  Must be integer"
    echo
    exit 1
}

# Parse options
while getopts "i:o:t:a:w:h:" opt; do
    case $opt in
        i) INPUT_DIR="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        t) IMAGE_TYPE="$OPTARG" ;;
        a) CROP_ANCHOR="$OPTARG" ;;
        w) CROP_WIDTH="$OPTARG" ;;
        h) CROP_HEIGHT="$OPTARG" ;;
        *) usage ;;
    esac
done

# Ensure input directory exists
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Invalid input directory: $INPUT_DIR."
    usage
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"
if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "Invalid output directory: $OUTPUT_DIR."
    usage
fi

if [[ ! "$IMAGE_TYPE" =~ ^(jpg|jpeg|png|bmp|webp)$ ]]; then
    echo "Invalid image type: $IMAGE_TYPE."
    usage
fi

# Ensure anchor is valid
if [[ ! "$CROP_ANCHOR" =~ ^(center|topleft|topcenter|topright|bottomleft|bottomcenter|bottomright|middleleft|middleright)$ ]]; then
    echo "Invalid anchor: $CROP_ANCHOR."
    usage
fi

# Check if crop dimensions are integers
if ! [[ "$CROP_WIDTH" =~ ^[0-9]+$ && "$CROP_HEIGHT" =~ ^[0-9]+$ ]]; then
    echo "Invalid crop dimensions: $CROP_WIDTH x $CROP_HEIGHT."
    usage
fi

# Process files
for file in "$INPUT_DIR"/*."$IMAGE_TYPE"; do
    filename=$(basename "$file")
    output_file="$OUTPUT_DIR/$filename"

    if [[ -f "$output_file" ]]; then
        echo "Skipping $filename: already exists."
        continue
    fi

    # Get image dimensions
    read IMAGE_WIDTH IMAGE_HEIGHT < <(magick identify -format "%w %h" "$file")

    # Sanity check
    if (( IMAGE_WIDTH < CROP_WIDTH || IMAGE_HEIGHT < CROP_HEIGHT )); then
    echo "Skipping $filename: image too small"
    continue
    fi

    # Calculate offsets
    case "$CROP_ANCHOR" in
    center)
        OFFSET_X=$(( (IMAGE_WIDTH - CROP_WIDTH) / 2 ))
        OFFSET_Y=$(( (IMAGE_HEIGHT - CROP_HEIGHT) / 2 ))
        ;;
    topleft)
        OFFSET_X=0; OFFSET_Y=0 ;;
    topcenter)
        OFFSET_X=$(( (IMAGE_WIDTH - CROP_WIDTH) / 2 )); OFFSET_Y=0 ;;
    topright)
        OFFSET_X=$(( IMAGE_WIDTH - CROP_WIDTH )); OFFSET_Y=0 ;;
    bottomleft)
        OFFSET_X=0; OFFSET_Y=$(( IMAGE_HEIGHT - CROP_HEIGHT )) ;;
    bottomcenter)
        OFFSET_X=$(( (IMAGE_WIDTH - CROP_WIDTH) / 2 )); OFFSET_Y=$(( IMAGE_HEIGHT - CROP_HEIGHT )) ;;
    bottomright)
        OFFSET_X=$(( IMAGE_WIDTH - CROP_WIDTH )); OFFSET_Y=$(( IMAGE_HEIGHT - CROP_HEIGHT )) ;;
    middleleft)
        OFFSET_X=0; OFFSET_Y=$(( (IMAGE_HEIGHT - CROP_HEIGHT) / 2 )) ;;
    middleright)
        OFFSET_X=$(( IMAGE_WIDTH - CROP_WIDTH )); OFFSET_Y=$(( (IMAGE_HEIGHT - CROP_HEIGHT) / 2 )) ;;
    *)
        echo "Invalid anchor: $CROP_ANCHOR"
        exit 1
        ;;
    esac

    # Crop the image
    echo "Cropping $filename..."
    ( magick "$file" -crop "${CROP_WIDTH}x${CROP_HEIGHT}+${OFFSET_X}+${OFFSET_Y}" +repage "$output_file" ) || {
        echo
        echo "Interrupted or failed on $filename"
        rm -f "$output_file"
        exit 1
    }
done

#Changelog
#2025-05-21 - AS - v1, First release.

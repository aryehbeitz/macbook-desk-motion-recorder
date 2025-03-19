#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"
mkdir -p "$WATCH_DIR"

MAIN_CAM_INDEX="0"  # Main Camera
TIMESTAMP="$1"  # Passed from watch.sh

# Ensure a timestamp is provided
if [ -z "$TIMESTAMP" ]; then
    TIMESTAMP=$(date +"%Y_%m_%d_%H_%M_%S")
fi

# Calculate end second (30s later)
END_SECOND=$(date -j -v+30S +"%S")

VIDEO_FILE="$WATCH_DIR/${TIMESTAMP}_recording-${END_SECOND}.mov"

# Use Main Camera (Device Index 0) for recording with correct pixel format (silent)
ffmpeg -f avfoundation -framerate 30 -video_size 1920x1080 -pixel_format uyvy422 -i "$MAIN_CAM_INDEX" -t 30 "$VIDEO_FILE" -loglevel error -nostats 2>/dev/null
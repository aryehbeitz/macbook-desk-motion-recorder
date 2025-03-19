#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"
mkdir -p "$WATCH_DIR"

MAIN_CAM_INDEX="0"  # Main Camera

# Function to clean up on exit
cleanup() {
    exit 0
}

# Trap Ctrl+C (SIGINT) to run cleanup()
trap cleanup SIGINT

# Get the start timestamp
START_TIMESTAMP=$(date +"%Y_%m_%d_%H_%M_%S")
END_SECOND=$(date -j -v+30S +"%S")  # Adds 30 seconds

VIDEO_FILE="$WATCH_DIR/recording_${START_TIMESTAMP}-${END_SECOND}.mov"

# Use Main Camera (Device Index 0) for recording with correct pixel format (silent)
ffmpeg -f avfoundation -framerate 30 -video_size 1920x1080 -pixel_format uyvy422 -i "$MAIN_CAM_INDEX" -t 30 "$VIDEO_FILE" -loglevel error -nostats 2>/dev/null
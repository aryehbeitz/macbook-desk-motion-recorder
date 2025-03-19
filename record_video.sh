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

VIDEO_FILE="$WATCH_DIR/recording_$(date +%Y%m%d_%H%M%S).mov"

# Use Main Camera (Device Index 0) for recording with correct pixel format (silent)
ffmpeg -f avfoundation -framerate 30 -video_size 1920x1080 -pixel_format uyvy422 -i "$MAIN_CAM_INDEX" -t 30 "$VIDEO_FILE" -loglevel error -nostats 2>/dev/null
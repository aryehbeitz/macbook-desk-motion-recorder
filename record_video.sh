#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"
mkdir -p "$WATCH_DIR"

MAIN_CAM_INDEX="0"  # Main Camera

while true; do
    VIDEO_FILE="$WATCH_DIR/recording_$(date +%Y%m%d_%H%M%S).mov"
    echo "Recording video to $VIDEO_FILE"

    # Use Main Camera (Device Index 0) for recording with correct pixel format
    ffmpeg -f avfoundation -framerate 30 -video_size 1920x1080 -pixel_format uyvy422 -i "$MAIN_CAM_INDEX" -t 30 "$VIDEO_FILE"

    sleep 1  # Short delay before starting next clip
done
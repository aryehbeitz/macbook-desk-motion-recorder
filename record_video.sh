#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"
mkdir -p "$WATCH_DIR"

while true; do
    VIDEO_FILE="$WATCH_DIR/recording_$(date +%Y%m%d_%H%M%S).mov"
    echo "Recording video to $VIDEO_FILE"
    
    ffmpeg -f avfoundation -framerate 30 -video_size 1280x720 -pixel_format uyvy422 -i "0" -t 30 "$VIDEO_FILE"

    sleep 1  # Short delay before starting next clip
done

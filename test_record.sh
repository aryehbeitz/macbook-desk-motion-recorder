#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"
mkdir -p "$WATCH_DIR"

VIDEO_FILE="$WATCH_DIR/test_recording_$(date +%Y%m%d_%H%M%S).mov"

# Use Desk View Camera (Device Index 1) with correct resolution (1920x1440) and 30fps
ffmpeg -f avfoundation -framerate 30 -video_size 1920x1440 -pixel_format uyvy422 -i "1" -t 10 "$VIDEO_FILE"

echo "Recording complete: $VIDEO_FILE"
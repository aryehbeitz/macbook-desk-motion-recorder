#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"
mkdir -p "$WATCH_DIR"

PREV_IMG="$WATCH_DIR/prev.jpg"
CURR_IMG="$WATCH_DIR/curr.jpg"

THRESHOLD=3000  # Motion sensitivity
RECORDING=false  # Track recording state
RECORD_PID=0  # Process ID of recording
DESK_CAM_INDEX="1"  # Desk View Camera

FRAME_CAPTURE_OPTIONS="-f avfoundation -video_size 1920x1440 -framerate 30 -pixel_format uyvy422 -i $DESK_CAM_INDEX -frames:v 1"

# Function to clean up on exit
cleanup() {
    if [ "$RECORDING" = true ]; then
        kill "$RECORD_PID" 2>/dev/null
    fi
    pkill -f record_video.sh 2>/dev/null  # Ensure all recording processes are stopped
    exit 0
}

# Trap Ctrl+C (SIGINT) to run cleanup()
trap cleanup SIGINT

# Capture initial frame using ffmpeg (silent)
ffmpeg $FRAME_CAPTURE_OPTIONS "$PREV_IMG" -y -loglevel error -nostats 2>/dev/null

if [ ! -f "$PREV_IMG" ]; then
    exit 1
fi

while true; do
    # Capture new frame using ffmpeg (silent)
    ffmpeg $FRAME_CAPTURE_OPTIONS "$CURR_IMG" -y -loglevel error -nostats 2>/dev/null

    if [ ! -f "$CURR_IMG" ]; then
        sleep 1
        continue
    fi

    # Compare full images for motion detection
    DIFF=$(magick compare -metric RMSE "$PREV_IMG" "$CURR_IMG" null: 2>&1 | awk '{print $1}')

    if (( $(echo "$DIFF > $THRESHOLD" | bc -l) )); then
        if [ "$RECORDING" = false ]; then
            RECORDING=true
            ./record_video.sh &  # Start recording in the background
            RECORD_PID=$!  # Capture PID of recording process
        fi
    else
        if [ "$RECORDING" = true ]; then
            kill "$RECORD_PID" 2>/dev/null  # Stop recording process
            RECORDING=false
        fi
    fi

    mv "$CURR_IMG" "$PREV_IMG"
    sleep 1
done
#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"
mkdir -p "$WATCH_DIR"

PREV_IMG="$WATCH_DIR/prev.jpg"
CURR_IMG="$WATCH_DIR/curr.jpg"
CENTER_PREV="$WATCH_DIR/prev_right.jpg"
CENTER_CURR="$WATCH_DIR/curr_right.jpg"

THRESHOLD=3000  # Adjust motion sensitivity
RECORDING=false  # Tracking recording state
RECORD_PID=0  # Process ID of recording

# Start motion detection loop
imagesnap -q -w 1 "$PREV_IMG"

while true; do
    imagesnap -q -w 1 "$CURR_IMG"

    # Crop the **right half** of the image (50% width, full height)
    magick "$PREV_IMG" -gravity East -crop 50%x100%+0+0 "$CENTER_PREV"
    magick "$CURR_IMG" -gravity East -crop 50%x100%+0+0 "$CENTER_CURR"

    # Compare the cropped right-side regions
    DIFF=$(magick compare -metric RMSE "$CENTER_PREV" "$CENTER_CURR" null: 2>&1 | awk '{print $1}')

    if (( $(echo "$DIFF > $THRESHOLD" | bc -l) )); then
        echo "Motion detected on the right side!"
        
        if [ "$RECORDING" = false ]; then
            echo "Starting recording..."
            RECORDING=true
            ./record_video.sh &  # Start recording in the background
            RECORD_PID=$!  # Capture PID of recording process
        fi
    else
        echo "No motion detected."
        
        if [ "$RECORDING" = true ]; then
            echo "Stopping recording..."
            kill "$RECORD_PID" 2>/dev/null  # Stop recording process
            RECORDING=false
        fi
    fi

    mv "$CURR_IMG" "$PREV_IMG"
    sleep 1
done
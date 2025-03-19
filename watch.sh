#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"
mkdir -p "$WATCH_DIR"

PREV_IMG="$WATCH_DIR/prev.jpg"
CURR_IMG="$WATCH_DIR/curr.jpg"
CENTER_PREV="$WATCH_DIR/prev_right.jpg"
CENTER_CURR="$WATCH_DIR/curr_right.jpg"
VIDEO_FILE="$WATCH_DIR/recording_$(date +%Y%m%d_%H%M%S).mov"

# Take an initial snapshot
imagesnap -q -w 1 "$PREV_IMG"

while true; do
    imagesnap -q -w 1 "$CURR_IMG"

    # Crop the **right half** of the image (50% width, full height)
    magick "$PREV_IMG" -gravity East -crop 50%x100%+0+0 "$CENTER_PREV"
    magick "$CURR_IMG" -gravity East -crop 50%x100%+0+0 "$CENTER_CURR"

    # Compare the cropped right-side regions
    DIFF=$(magick compare -metric RMSE "$CENTER_PREV" "$CENTER_CURR" null: 2>&1 | awk '{print $1}')

    # Motion threshold (tune this value if needed)
    THRESHOLD=3000

    if (( $(echo "$DIFF > $THRESHOLD" | bc -l) )); then
        echo "Person detected on the right side! Starting recording..."
        
        # Use FaceTime HD Camera (usually index 0) and fix pixel format issues
        ffmpeg -f avfoundation -framerate 30 -video_size 1280x720 -pixel_format uyvy422 -i "0" -t 30 "$VIDEO_FILE"
        break
    fi

    mv "$CURR_IMG" "$PREV_IMG"
    sleep 1
done
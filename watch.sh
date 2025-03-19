#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"
mkdir -p "$WATCH_DIR"

PREV_IMG="$WATCH_DIR/prev.jpg"
CURR_IMG="$WATCH_DIR/curr.jpg"

# The minimum percentage of changed pixels required to trigger a recording.
# Adjust this value based on sensitivity needs:
# - Too many false positives? Increase PIXEL_CHANGE_THRESHOLD (e.g., 3.5 or 5.0).
# - Not detecting movement fast enough? Decrease it (e.g., 1.0 or 0.5).
PIXEL_CHANGE_THRESHOLD=2.0  

DESK_CAM_INDEX="1"  # Desk View Camera
FRAME_CAPTURE_OPTIONS="-f avfoundation -video_size 1920x1440 -framerate 30 -pixel_format uyvy422 -i $DESK_CAM_INDEX -frames:v 1"

# Function to clean up on exit
cleanup() {
    echo "[INFO] Stopping motion detection."
    exit 0
}

# Trap Ctrl+C (SIGINT) to run cleanup()
trap cleanup SIGINT

echo "[INFO] Motion detection started. Monitoring Desk View Camera..."

# Capture initial frame using ffmpeg (silent)
ffmpeg $FRAME_CAPTURE_OPTIONS "$PREV_IMG" -y -loglevel error -nostats 2>/dev/null

if [ ! -f "$PREV_IMG" ]; then
    echo "[ERROR] Failed to capture initial image. Exiting..."
    exit 1
fi

while true; do
    echo "[INFO] Checking for movement..."

    # Capture new frame using ffmpeg (silent)
    ffmpeg $FRAME_CAPTURE_OPTIONS "$CURR_IMG" -y -loglevel error -nostats 2>/dev/null

    if [ ! -f "$CURR_IMG" ]; then
        echo "[WARNING] Failed to capture current image. Retrying..."
        sleep 1
        continue
    fi

    # Compute pixel difference using ImageMagick
    DIFF_PIXELS=$(magick compare -metric AE "$PREV_IMG" "$CURR_IMG" null: 2>&1 | awk '{print $1}')
    
    # Ensure DIFF_PIXELS is a valid number
    if ! [[ "$DIFF_PIXELS" =~ ^[0-9]+$ ]]; then
        echo "[ERROR] Invalid DIFF_PIXELS value ($DIFF_PIXELS). Skipping frame..."
        sleep 1
        continue
    fi

    # Compute total image pixels
    WIDTH=$(magick identify -format "%w" "$CURR_IMG")
    HEIGHT=$(magick identify -format "%h" "$CURR_IMG")
    TOTAL_PIXELS=$((WIDTH * HEIGHT))

    # Ensure TOTAL_PIXELS is a valid number and greater than zero
    if ! [[ "$TOTAL_PIXELS" =~ ^[0-9]+$ ]] || [ "$TOTAL_PIXELS" -eq 0 ]; then
        echo "[ERROR] Invalid TOTAL_PIXELS value ($TOTAL_PIXELS). Skipping frame..."
        sleep 1
        continue
    fi

    # Compute the percentage of changed pixels
    DIFF_PERCENT=$(awk "BEGIN { printf \"%.2f\", ($DIFF_PIXELS / $TOTAL_PIXELS) * 100 }")

    # Ensure DIFF_PERCENT is within a reasonable range (0% - 100%)
    if (( $(echo "$DIFF_PERCENT > 100" | bc -l) )); then
        echo "[ERROR] DIFF_PERCENT ($DIFF_PERCENT%) is unrealistic. Skipping frame..."
        sleep 1
        continue
    fi

    if (( $(echo "$DIFF_PERCENT > $PIXEL_CHANGE_THRESHOLD" | bc -l) )); then
        TIMESTAMP=$(date +"%Y_%m_%d_%H_%M_%S")

        PREV_IMAGE="$WATCH_DIR/${TIMESTAMP}_trigger_prev.jpg"
        CURR_IMAGE="$WATCH_DIR/${TIMESTAMP}_trigger_curr.jpg"

        cp "$PREV_IMG" "$PREV_IMAGE"
        cp "$CURR_IMG" "$CURR_IMAGE"

        echo "[ALERT] Movement detected! Diff Level: $DIFF_PERCENT%"
        echo "[INFO] Saving trigger images: $PREV_IMAGE, $CURR_IMAGE"
        echo "[INFO] Starting recording..."

        ./record_video.sh "$TIMESTAMP"

        echo "[INFO] Recording finished. Pausing detection for 10 seconds..."
        sleep 10
    else
        echo "[INFO] No significant movement detected. Diff Level: $DIFF_PERCENT%"
    fi

    mv "$CURR_IMG" "$PREV_IMG"
    sleep 1
done
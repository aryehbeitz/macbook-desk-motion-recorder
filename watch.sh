#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"
mkdir -p "$WATCH_DIR"
mkdir -p "$WATCH_DIR/.tmp"

PREV_IMG="$WATCH_DIR/.tmp/prev.jpg"
PREV_IMG_2="$WATCH_DIR/.tmp/prev_2.jpg"
PREV_IMG_3="$WATCH_DIR/.tmp/prev_3.jpg"
CURR_IMG="$WATCH_DIR/.tmp/curr.jpg"

# The minimum percentage of changed pixels required to trigger a recording.
# - Too many false positives? Increase PIXEL_CHANGE_THRESHOLD (e.g., 0.6 or 1.0).
# - Not detecting movement fast enough? Decrease it (e.g., 0.3 or 0.2).
PIXEL_CHANGE_THRESHOLD=0.4

DESK_CAM_INDEX="1"  # Desk View Camera
FRAME_CAPTURE_OPTIONS="-f avfoundation -video_size 1920x1440 -framerate 30 -pixel_format uyvy422 -i $DESK_CAM_INDEX -frames:v 1"

# Function to display images in terminal
show_image() {
    local image_path="$1"
    if [ -n "$KITTY_WINDOW_ID" ]; then
        # Kitty terminal
        printf '\033_Ga=T,f=100,i=1;%s\033\\' "$(base64 -i "$image_path")"
    elif [ -n "$ITERM_PROFILE" ]; then
        # iTerm2
        printf '\033]1337;File=inline=1:%s\a' "$(base64 -i "$image_path")"
    else
        # Fallback to ASCII art using ImageMagick
        convert "$image_path" -resize 80x40 -colorspace gray -format txt:- | \
            sed -n 's/^.*(\([0-9,]*\))$/\1/p' | \
            tr -d ',' | \
            awk '{printf "%c", int($1/255*93+32)}'
    fi
}

# Function to clear terminal
clear_terminal() {
    if [ -n "$KITTY_WINDOW_ID" ] || [ -n "$ITERM_PROFILE" ]; then
        clear
    else
        echo -e "\033[2J\033[H"
    fi
}

# Function to clean up on exit
cleanup() {
    echo "[INFO] Cleaning up temporary files..."
    rm -rf "$WATCH_DIR/.tmp"
    echo "[INFO] Stopping motion detection."
    exit 0
}

# Trap Ctrl+C (SIGINT) to run cleanup()
trap cleanup SIGINT

echo "[INFO] Motion detection started. Monitoring Desk View Camera..."

# Capture initial frame using ffmpeg (silent)
ffmpeg $FRAME_CAPTURE_OPTIONS "$PREV_IMG" -y -loglevel error -nostats 2>/dev/null
cp "$PREV_IMG" "$PREV_IMG_2"
cp "$PREV_IMG" "$PREV_IMG_3"

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

    # Compare RMSE values for last 3 frames
    DIFF_1=$(magick compare -metric RMSE "$PREV_IMG" "$CURR_IMG" null: 2>&1 | awk '{print $1}')
    DIFF_2=$(magick compare -metric RMSE "$PREV_IMG_2" "$CURR_IMG" null: 2>&1 | awk '{print $1}')
    DIFF_3=$(magick compare -metric RMSE "$PREV_IMG_3" "$CURR_IMG" null: 2>&1 | awk '{print $1}')

    # Fix for BSD AWK on macOS: Determine max difference value without nested ternary
    if (( $(echo "$DIFF_1 > $DIFF_2" | bc -l) )); then
        if (( $(echo "$DIFF_1 > $DIFF_3" | bc -l) )); then
            DIFF_VALUE="$DIFF_1"
        else
            DIFF_VALUE="$DIFF_3"
        fi
    else
        if (( $(echo "$DIFF_2 > $DIFF_3" | bc -l) )); then
            DIFF_VALUE="$DIFF_2"
        else
            DIFF_VALUE="$DIFF_3"
        fi
    fi

    # Ensure DIFF_VALUE is a valid number
    if ! [[ "$DIFF_VALUE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "[ERROR] Invalid DIFF_VALUE ($DIFF_VALUE). Skipping frame..."
        sleep 1
        continue
    fi

    # Compute total image pixels
    WIDTH=$(magick identify -format "%w" "$CURR_IMG")
    HEIGHT=$(magick identify -format "%h" "$CURR_IMG")
    TOTAL_PIXELS=$((WIDTH * HEIGHT))

    # Ensure TOTAL_PIXELS is a valid number
    if ! [[ "$TOTAL_PIXELS" =~ ^[0-9]+$ ]] || [ "$TOTAL_PIXELS" -eq 0 ]; then
        echo "[ERROR] Invalid TOTAL_PIXELS value ($TOTAL_PIXELS). Skipping frame..."
        sleep 1
        continue
    fi

    # Compute the percentage of changed pixels
    DIFF_PERCENT=$(awk "BEGIN { printf \"%.2f\", ($DIFF_VALUE / $TOTAL_PIXELS) * 100 }")

    if (( $(echo "$DIFF_PERCENT > 100" | bc -l) )); then
        echo "[ERROR] DIFF_PERCENT ($DIFF_PERCENT%) is unrealistic. Skipping frame..."
        sleep 1
        continue
    fi

    if (( $(echo "$DIFF_PERCENT > $PIXEL_CHANGE_THRESHOLD" | bc -l) )); then
        TIMESTAMP=$(date +"%Y_%m_%d_%H_%M_%S")

        # Create a visual diff image showing what changed
        DIFF_IMAGE="$WATCH_DIR/${TIMESTAMP}_diff.jpg"
        magick compare "$PREV_IMG" "$CURR_IMG" -compose src -highlight-color red "$DIFF_IMAGE"

        echo "[ALERT] Movement detected! Diff Level: $DIFF_PERCENT%"
        echo "[INFO] Saving diff image: $DIFF_IMAGE"

        # Show the images in terminal
        clear_terminal
        echo "Previous Frame:"
        show_image "$PREV_IMG"
        echo -e "\nCurrent Frame:"
        show_image "$CURR_IMG"
        echo -e "\nDifference (red highlights changes):"
        show_image "$DIFF_IMAGE"
        echo -e "\n[INFO] Starting recording..."

        ./record_video.sh "$TIMESTAMP"

        echo "[INFO] Recording finished. Cleaning up temporary files..."
        rm -f "$PREV_IMG" "$PREV_IMG_2" "$PREV_IMG_3" "$CURR_IMG"

        # Reinitialize the image files for the next cycle
        ffmpeg $FRAME_CAPTURE_OPTIONS "$PREV_IMG" -y -loglevel error -nostats 2>/dev/null
        cp "$PREV_IMG" "$PREV_IMG_2"
        cp "$PREV_IMG" "$PREV_IMG_3"

        echo "[INFO] Pausing detection for 10 seconds..."
        sleep 10
    else
        echo "[INFO] No significant movement detected. Diff Level: $DIFF_PERCENT%"
    fi

    # Shift frames to compare against older frames next cycle
    mv "$PREV_IMG_2" "$PREV_IMG_3"
    mv "$PREV_IMG" "$PREV_IMG_2"
    mv "$CURR_IMG" "$PREV_IMG"

    sleep 1
done

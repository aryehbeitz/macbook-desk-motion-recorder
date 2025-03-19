#!/bin/bash

WATCH_DIR="$HOME/Desktop/security"

# Check if directory exists
if [ ! -d "$WATCH_DIR" ]; then
    echo "[ERROR] Security directory not found: $WATCH_DIR"
    exit 1
fi

# Count files to be deleted
FILE_COUNT=$(find "$WATCH_DIR" -type f ! -path "*/\.*" | wc -l | tr -d ' ')
if [ "$FILE_COUNT" -eq 0 ]; then
    echo "[INFO] No recordings found in $WATCH_DIR"
    exit 0
fi

# Ask for confirmation
echo "[WARNING] This will delete $FILE_COUNT recording(s) from $WATCH_DIR"
read -p "Are you sure you want to proceed? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "[INFO] Operation cancelled"
    exit 0
fi

# Remove all files except hidden files/directories
find "$WATCH_DIR" -type f ! -path "*/\.*" -delete

# Also clean the .tmp directory if it exists
if [ -d "$WATCH_DIR/.tmp" ]; then
    rm -rf "$WATCH_DIR/.tmp"/*
fi

echo "[INFO] Successfully cleaned $FILE_COUNT recording(s) from $WATCH_DIR"

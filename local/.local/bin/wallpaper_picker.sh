#!/bin/bash

# --- Configuration ---
WALL_DIR="$HOME/Pictures/wallpapers"
TRANSITION_TYPE="center"   # simple, fade, left, right, top, bottom, wipe, wave, grow, center, outer, random
TRANSITION_STEP=90
TRANSITION_FPS=60

# --- Check Dependencies ---
if ! command -v swww &> /dev/null; then echo "Error: swww is not installed." && exit 1; fi
if ! command -v matugen &> /dev/null; then echo "Error: matugen is not installed." && exit 1; fi

# --- 1. Select Wallpaper (using Fuzzel) ---
# We find files, strip the path for the menu, then reconstruct it
SELECTED_FILE=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%f\n" | sort | fuzzel -d -p "󰸉  " --width 40 --lines 10)

# Exit if no file selected (user pressed Esc)
if [ -z "$SELECTED_FILE" ]; then
    exit 0
fi

FULL_PATH="$WALL_DIR/$SELECTED_FILE"

# --- 2. Apply Wallpaper (swww) ---
echo ":: Setting wallpaper with swww..."
swww img "$FULL_PATH" \
    --transition-type "$TRANSITION_TYPE" \
    --transition-step "$TRANSITION_STEP" \
    --transition-fps "$TRANSITION_FPS"

# --- 3. Generate Colors (Matugen) ---
echo ":: Generating Matugen colors..."
# This will trigger all the templates defined in your config.toml
matugen image "$FULL_PATH"

# --- 4. Generate Colors (Pywal16) ---
echo ":: Generating Pywal16 colors..."
# -n tells pywal NOT to set the wallpaper (swww handles it)
# -s skips setting terminal colors immediately (optional, remove -s if you want instant terminal change)
if command -v pywal16 &> /dev/null; then
    pywal16 -i "$FULL_PATH" -n
elif command -v wal &> /dev/null; then
    # Fallback to standard 'wal' if pywal16 is installed as 'wal'
    wal -i "$FULL_PATH" -n
else
    echo "Warning: Pywal16/wal not found."
fi

# --- 5. Optional: Send Notification ---
notify-send "Theme Updated" "Wallpaper: $SELECTED_FILE" -i "$FULL_PATH"

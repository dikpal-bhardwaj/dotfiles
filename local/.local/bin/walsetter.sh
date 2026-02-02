#!/bin/bash

# --- CONFIGURATION ---
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
ROFI_THEME_FILE="$HOME/.config/rofi/wallpaper-selector.rasi"

# --- 1. PRE-FLIGHT CHECKS ---
if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick is not installed. Run: sudo pacman -S imagemagick"
    exit 1
fi

mkdir -p "$CACHE_DIR"

# --- 2. THUMBNAIL GENERATION ---
shopt -s nullglob
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp}; do
    filename=$(basename "$img")
    thumb="$CACHE_DIR/$filename"
    if [ ! -f "$thumb" ]; then
        echo "Generating thumb: $filename"
        magick "$img" -strip -resize 500x500^ -gravity center -extent 500x500 "$thumb"
    fi
done

# --- 3. ROFI THEME GENERATION ---
cat > "$ROFI_THEME_FILE" << EOF
@import "~/.config/rofi/colors.rasi"

* {
    background-color: transparent;
    text-color:       @on-surface;
}

window {
    background-color: @surface;
    border:           2px;
    border-color:     @primary;
    border-radius:    12px;
    width:            60%;
    height:           55%;
    padding:          20px;
}

mainbox {
    children: [ inputbar, listview ];
    spacing: 15px;
}

inputbar {
    background-color: @surface-container;
    padding: 12px;
    border-radius: 8px;
    children: [ prompt, entry ];
    margin: 0 0 10px 0;
}

prompt {
    text-color: @primary;
    padding: 0 10px 0 0;
}

entry {
    placeholder: "Search Wallpaper...";
    placeholder-color: @outline;
}

listview {
    columns: 4;
    lines:   2;
    cycle:   false;
    dynamic: true;
    layout:  vertical;
    flow:    horizontal;
    spacing: 15px;
}

element {
    orientation: vertical;
    padding:     15px;
    border-radius: 8px;
    cursor: pointer;
}

element selected {
    background-color: @primary-container;
    border: 1px;
    border-color: @primary;
}

element-icon {
    size: 150px;
    horizontal-align: 0.5;
    vertical-align: 0.5;
    cursor: inherit;
}

element-text {
    enabled: false;
}
EOF

# --- 4. LAUNCH ROFI ---
# We pipe the FULL path as the hidden value, while the icon metadata uses the thumb
selected=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort | while read -r img_path; do
    filename=$(basename "$img_path")
    thumb="$CACHE_DIR/$filename"
    # Format: FullPath\0icon\x1fThumbnailPath
    echo -en "$img_path\0icon\x1f$thumb\n"
done | rofi -dmenu -no-config -show-icons -theme "$ROFI_THEME_FILE" -p "Wallpaper")

# --- 5. APPLY WALLPAPER (WITH REPAIR) ---
if [ -n "$selected" ]; then
    echo "Selected: $selected"
    
    # Try setting wallpaper using the full path returned by Rofi
    if ! swww img "$selected" --transition-type none; then
        echo "SWWW failed. Attempting repair..."
        
        killall swww-daemon 2>/dev/null
        rm -rf ~/.cache/swww
        
        # Updated to --format argb to fix the deprecation warning
        swww-daemon --format argb &
        sleep 1
        
        swww img "$selected" --transition-type none
    fi
    
    notify-send "Wallpaper Set" "$(basename "$selected")" -i "$selected"
fi

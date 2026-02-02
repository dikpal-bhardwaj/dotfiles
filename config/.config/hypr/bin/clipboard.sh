#!/usr/bin/env bash

tmp_dir="/tmp/cliphist_previews"
mkdir -p "$tmp_dir"
rm -f "$tmp_dir"/*

# Prepare entries with optional image previews for rofi
entries=$(cliphist list | while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Match lines with image extensions
    if [[ "$line" =~ ^([0-9]+)\s.*(png|jpg|jpeg|bmp)$ ]]; then
        id="${BASH_REMATCH[1]}"
        ext="${BASH_REMATCH[2]}"
        file="$tmp_dir/$id.$ext"

        # Decode image to temp file
        cliphist decode <<<"$id" >"$file"

        # Output with icon hint for rofi
        echo -e "$line\0icon\x1f$file"
    else
        # Output normal text line as is
        echo "$line"
    fi
done)

# Show clipboard history in rofi with theme
chosen=$(echo -e "$entries" | rofi -dmenu -theme ~/.config/rofi/themes/clipboard.rasi -p "Clipboard")

# If selection made, decode and copy, then notify with swaync
if [ -n "$chosen" ]; then
    cliphist decode <<<"$chosen" | wl-copy
    swaync show "Copied from history"
fi

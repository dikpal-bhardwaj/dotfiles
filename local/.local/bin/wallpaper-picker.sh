#!/usr/bin/env bash

# --- CONFIG ---
WALL_DIR="$HOME/Pictures/wallpapers"
SYMLINK="$HOME/.config/hypr/current_wallpaper"
ROFI_CONF="$HOME/.config/rofi/wallpaper-grid.rasi"

# Ensure swww is running
swww query || swww-daemon &

# 1. Generate the list of files with Rofi icon formatting
# Format: "filename\0icon\x1f/path/to/file"
mapfile -t images < <(ls "$WALL_DIR" | grep -E ".jpg$|.jpeg$|.png$|.webp$")

rofi_input=""
for img in "${images[@]}"; do
    rofi_input+="$img\x00icon\x1f$WALL_DIR/$img\n"
done

# 2. Launch Rofi
selected_name=$(echo -e "$rofi_input" | rofi -dmenu -i -p "Select Wallpaper" -config "$ROFI_CONF")

# Exit if no selection
[[ -z "$selected_name" ]] && exit 0

FULL_PATH="$WALL_DIR/$selected_name"

# 3. Apply changes
ln -sf "$FULL_PATH" "$SYMLINK"
swww img "$FULL_PATH" --transition-type center --transition-fps 60

# 4. Color Generation
matugen image "$FULL_PATH"
[ -f "$HOME/.cache/wal/colors.sh" ] && . "$HOME/.cache/wal/colors.sh"
pywal16 -i "$FULL_PATH" -n || wal -i "$FULL_PATH" -n

# 5. Refresh Components
pkill -SIGUSR2 waybar
notify-send -a "Wallpaper Selector" -i "$FULL_PATH" "Theme Updated"

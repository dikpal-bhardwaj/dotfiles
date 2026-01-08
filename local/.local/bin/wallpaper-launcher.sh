#!/bin/bash
#  ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗
#  ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
#  ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝
#  ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
#  ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║
#   ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
#
#  ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
#  ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║██╔════╝██╔══██╗
#  ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║█████╗  ██████╔╝
#  ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║██╔══╝  ██╔══██╗
#  ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗██║  ██║
#  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

# 1. FIX: Add local bin to PATH so keybindings can find 'wal', 'rofi', etc.
export PATH="${HOME}/.local/bin:${PATH}"

# Set variables
wall_dir="${HOME}/Pictures/Wallpapers"
cacheDir="${HOME}/.cache/jp/${theme}"

# 2. FIX: Hardcode cursor settings (Environment variables for the script execution)
export XCURSOR_THEME="Bibata-Modern-Classic"
export XCURSOR_SIZE=20
export HYPRCURSOR_THEME="Bibata-Modern-Classic"
export HYPRCURSOR_SIZE=20

# 3. FIX: Simplified Rofi sizing.
# Your complicated 'hyprctl' math was failing (dividing by zero).
# For a 1366x768 screen, a fixed icon size of 120px or 150px works perfectly.
rofi_override="element-icon{size:200px;border-radius:0px;}"

rofi_command="rofi -dmenu -theme ${HOME}/.config/rofi/wallSelect.rasi -theme-str ${rofi_override}"

# Create cache dir if not exists
if [ ! -d "${cacheDir}" ]; then
    mkdir -p "${cacheDir}"
fi

physical_monitor_size=24
monitor_res=$(hyprctl monitors | grep -A2 Monitor | head -n 2 | awk '{print $1}' | grep -oE '^[0-9]+')
dotsperinch=$(echo "scale=2; $monitor_res / $physical_monitor_size" | bc | xargs printf "%.0f")
monitor_res=$(($monitor_res * $physical_monitor_size / $dotsperinch))

rofi_override="element-icon{size:${monitor_res}px;border-radius:0px;}"

# Convert images in directory and save to cache dir
for imagen in ~/Pictures/Wallpapers/*.{jpg,jpeg,png}; do
    [ -f "$imagen" ] || continue
    nombre_archivo=$(basename "$imagen")
    output="${HOME}/.cache/jp/${nombre_archivo}"
    if [ ! -f "$output" ]; then
        magick "$imagen" -strip -thumbnail 320x180^ -gravity center -extent 320x180 "$output"
    fi
done

# Select a picture with rofi
wall_selection=$(find "${wall_dir}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A; do echo -en "$A\x00icon\x1f""${cacheDir}"/"$A\n"; done | $rofi_command)

[[ -n "$wall_selection" ]] || exit 1

# >>> Full path to chosen wallpaper
chosen_wall="${wall_dir}/${wall_selection}"

# Set the wallpaper
swww img "${wall_dir}/${wall_selection}" \
  --transition-type grow \
  --transition-pos center \
  --transition-duration 2.5 \
  --transition-fps 60
  # --transition-step 2

# >>> Update Hyprlock symlink so it always points to the current wallpaper
ln -sf "${chosen_wall}" "${HOME}/.config/hypr/current_wallpaper"

# === Sync Colors ===
# 4. FIX: Removed -s (so terminals update) and ensured command runs
wal -i "${wall_dir}/${wall_selection}" -n -t -e

# Reload Waybar
if pgrep -x "waybar" >/dev/null; then
    pkill waybar && waybar &
else
    waybar &
fi

# Reload SwayNC
swaync-client -rs

# Notify
notify-send "Wallpaper updated" "Colors synced successfully."

exit 0

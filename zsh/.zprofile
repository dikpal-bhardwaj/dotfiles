# export XCURSOR_THEME=Bibata-Modern-Classic
# export XCURSOR_SIZE=20
# export HYPRCURSOR_THEME=Bibata-Modern-Classic
# export HYPRCURSOR_SIZE=20

if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    # exec Hyprland
    # exec startx
    # exec /home/dikpal/.local/bin/start_dwl.sh
    exec niri
fi

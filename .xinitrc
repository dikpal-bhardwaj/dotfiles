# Set screen resolution
xrandr --output "$(xrandr | grep ' connected' | cut -d ' ' -f1)" --mode 1366x768

# dwmblocks &
slstatus &
picom &

# Set mouse cursor theme
export XCURSOR_THEME=Bibata-Modern-Ice
export XCURSOR_SIZE=20
xsetroot -cursor_name left_ptr

# Set wallpaper (if you use feh)
[ -f ~/.fehbg ] && ~/.fehbg &

# Enable natural scrolling and tap-to-click
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Natural Scrolling Enabled" 1
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1

# Start DWM
exec dwm


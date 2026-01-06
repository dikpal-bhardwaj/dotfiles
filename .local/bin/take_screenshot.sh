#!/bin/sh
timeout 10 slurp >/tmp/selection.txt 2>/dev/null
if [ $? -eq 0 ] && [ -s /tmp/selection.txt ]; then
    grim -g "$(cat /tmp/selection.txt)" - | wl-copy
else
    grim - | wl-copy
fi
rm -f /tmp/selection.txt

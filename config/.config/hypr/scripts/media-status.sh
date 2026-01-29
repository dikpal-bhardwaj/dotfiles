#!/usr/bin/env bash

# Check if playerctl is running/available
if ! command -v playerctl &> /dev/null; then
    exit 0
fi

status=$(playerctl status 2>/dev/null)

if [[ "$status" == "Playing" ]]; then
    artist=$(playerctl metadata artist)
    title=$(playerctl metadata title)
    # Limit length to avoid screen overflow
    text="$artist - $title"
    if [[ ${#text} -gt 50 ]]; then
        echo "${text:0:50}..."
    else
        echo "$text"
    fi
elif [[ "$status" == "Paused" ]]; then
    echo "  $(playerctl metadata title)"
else
    echo "" # Empty string if nothing playing
fi

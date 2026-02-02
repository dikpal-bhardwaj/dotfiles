#!/bin/bash

# Get song metadata from playerctl
title=$(playerctl metadata title 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null)

# Show "Not Playing" if nothing found
if [ -z "$title" ]; then
    echo "⏹  Not Playing"
else
    echo "🎵  $artist - $title"
fi

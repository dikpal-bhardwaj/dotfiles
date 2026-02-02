#!/bin/bash

# Detect battery path (usually BAT0)
BATTERY=$(ls /sys/class/power_supply | grep BAT | head -n 1)
BAT_PATH="/sys/class/power_supply/$BATTERY"

# Read charge and status
CHARGE=$(cat "$BAT_PATH/capacity")
STATUS=$(cat "$BAT_PATH/status")

# Set icon based on charge level
if [[ "$STATUS" == "Charging" ]]; then
    ICON="⚡"
elif (( CHARGE >= 80 )); then
    ICON="🔋"
elif (( CHARGE >= 40 )); then
    ICON="🔋"
else
    ICON="🔻"
fi

# Output formatted string
echo "$ICON  $CHARGE% ($STATUS)"

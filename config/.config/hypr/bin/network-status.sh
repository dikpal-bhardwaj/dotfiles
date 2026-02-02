#!/bin/bash

# Try to get active network interface
IFACE=$(ip route | awk '/^default/ {print $5}' | head -n 1)

# If no interface, assume disconnected
if [[ -z "$IFACE" ]]; then
    echo "❌  Disconnected"
    exit
fi

# Get interface type: wireless or ethernet
if [[ -d "/sys/class/net/$IFACE/wireless" ]]; then
    TYPE="Wi-Fi"
    SSID=$(iw dev "$IFACE" info | awk '/ssid/ {print $2}')
    echo "📶  $SSID"
else
    TYPE="Ethernet"
    echo "🔌  Ethernet"
fi

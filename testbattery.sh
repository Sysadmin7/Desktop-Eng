#!bin/bash
# Test returning battery state.

STATE=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0| grep -E "state")
if [ "$STATE" != 'discharging' ]; then
        echo "Laptop not on AC Power"
fi
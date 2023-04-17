#!bin/bash
# Test returning battery state.

STATE=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state" | sed -e 's/state://ig');
if [ $STATE != 'discharging' ] then
        echo "Laptop is on battery"
else echo "Laptop is on AC Power"
fi
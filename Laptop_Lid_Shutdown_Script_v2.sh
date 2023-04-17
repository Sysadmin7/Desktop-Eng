#!/bin/bash
# IGEL Laptop Lid Shutdown Script
# Brandon - btoddr22@outlook.com
NAME=Laptop_Lid_Shutdown_Script
VERSION="1.0"
STATE=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state" | sed -e 's/state://ig');

echo "Lid Closed, Starting timer."
sleep 30m #Sleep the script for 30 minutes.
echo "Lid timer reached"

grep -q close /proc/acpi/button/lid/*/state #Check if the laptop lid is closed.
if [ $? = 0 ] && [ $STATE = 'discharging' ]; then #Check condition of battery status.
    systemctl poweroff #Issue the shutdown command.
grep -q open /proc/acpi/button/lid/*/state #Check if the laptop lid is open.
 [ $? = 0 ]; then
    echo "Lid is open. Not shutting down."
    exit; #Exit the script and do nothing.
fi

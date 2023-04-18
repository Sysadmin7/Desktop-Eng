#!/bin/bash
# IGEL Laptop Lid Shutdown Script
# Brandon - btoddr22@outlook.com
NAME=Laptop_Lid_Shutdown_Script
VERSION="1.0"

logger "Lid Closed, Starting timer."
sleep 30m #Sleep the script for 30 minutes.
STATE=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state" | sed -e 's/state://ig');
logger "Lid timer reached"

grep -q close /proc/acpi/button/lid/*/state #Check if the laptop lid is closed.
if [ $? = 0 ] && [ $STATE == 'discharging' ]; then #Check condition of battery status.
    systemctl poweroff #Issue the shutdown command.
    else 
    logger "Lid is open or on AC power. Not shutting down"
    exit; #Exit the script and do nothing.
fi

#!/bin/bash
# IGEL Laptop Lid Shutdown Script
# Brandon - btoddr22@outlook.com
NAME=Laptop_Lid_Shutdown_Script
VERSION="1.0"
echo "Lid Closed, Starting timer."
sleep 30m #Sleep the script for 30 minutes.
echo "Lid timer reached"
grep -q close /proc/acpi/button/lid/*/state #Check if the laptop lid is closed.
if [ $? = 0 ]; then
    systemctl poweroff #Issue the shutdown command.
fi
grep -q open /proc/acpi/button/lid/*/state #Check if the laptop lid is open.
if [ $? = 0 ]; then
    echo "Lid is open. Not shutting down."
    exit; #Exit the script and do nothing.
fi
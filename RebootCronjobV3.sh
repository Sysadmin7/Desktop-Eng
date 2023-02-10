#!/bin/bash
#IGEL Kiosk Reboot Script
name=IGEL_KioskReboot_Script
ver="0.3"
REBOOT_HOURS=720
MAXIMUM_DELAY_HOURS=2
MAXIMUM_SLEEP_SECONDS=$(($MAXIMUM_DELAY_HOURS * 3600))
UPTIME=`/usr/bin/printf %.0f $(/usr/bin/awk '{print $0/3600;}' /proc/uptime)`
SLEEP_TIME=$((1 + RANDOM % $MAXIMUM_SLEEP_SECONDS))
/bin/sleep $SLEEP_TIME
if ! /usr/bin/pgrep -x wfica > /dev/null; then
  if [ $UPTIME -ge $REBOOT_HOURS ]; then
    echo "${name} v${ver} : running /sbin/reboot"
    # /sbin/reboot
  else
    echo "${name} v${ver}: running /sbin/get_rmsettings"
    # /sbin/get_rmsettings
  fi
fi

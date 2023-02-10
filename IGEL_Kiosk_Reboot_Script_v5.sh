#!/bin/bash
# IGEL Kiosk Reboot Script v0.5
# Brandon - btoddr22@outlook.com
NAME=IGEL_Kiosk_Reboot_Script
VERSION="0.5"
DEBUG=true

REBOOT_HOURS=720
MAXIMUM_DELAY_HOURS=2
MAXIMUM_SLEEP_SECONDS=$(($MAXIMUM_DELAY_HOURS * 3600))
UPTIME=`/usr/bin/printf %.0f $(/usr/bin/awk '{print $0/3600;}' /proc/uptime)`
SLEEP_TIME=$((1 + RANDOM % $MAXIMUM_SLEEP_SECONDS)) #Randomization to prevent unhealthy loading on UMS.
#### DEBUGGING
if [ "$DEBUG" = true ]; then
  UPTIME=1
  REBOOT_HOURS=2
  SLEEP_TIME=1
fi
#### END_DEBUGGING
/bin/sleep $SLEEP_TIME
if ! /usr/bin/pgrep -x wfica > /dev/null; then #Find if Citrix is running using pgrep and 'Simple Logic' for returns.
  echo "${NAME} v${VERSION}: Citrix (wfica) NOT found running.  continuing..."
  if [ $UPTIME -ge $REBOOT_HOURS ]; then
    echo "${NAME} v${VERSION}: running /sbin/reboot"
    # /sbin/reboot
  else
    echo "${NAME} v${VERSION}: running /sbin/get_rmsettings"
    # /sbin/get_rmsettings
  fi
else
  echo "${NAME} v${VERSION}: Citrix (wfica) found running.  exiting..."
fi
#!/bin/bash
# IGEL Kiosk Reboot Script
# Brandon - btoddr22@outlook.com
NAME=IGEL_Kiosk_Reboot_Script
VERSION="0.6"
DEBUG=true

REBOOT_HOURS=720
MAXIMUM_DELAY_HOURS=2
MAXIMUM_SLEEP_SECONDS=$(($MAXIMUM_DELAY_HOURS * 3600))
UPTIME=`/usr/bin/printf %.0f $(/usr/bin/awk '{print $0/3600;}' /proc/uptime)`
SLEEP_TIME=$((1 + RANDOM % $MAXIMUM_SLEEP_SECONDS))
USERIDLE="$(DISPLAY=:0 /usr/bin/xprintidle)"
#### DEBUGGING
if [ "$DEBUG" = true ]; then
  UPTIME=1
  REBOOT_HOURS=2
  SLEEP_TIME=1
  USERIDLE=$((10*60*1000))   # in uSec (10 min = 10*60*1000)
fi
#### END_DEBUGGING
/bin/sleep $SLEEP_TIME
if ! /usr/bin/pgrep -x wfica > /dev/null; then
  echo "${NAME} v${VERSION}: Citrix (wfica) NOT found running.  continuing..."
  if [[ $USERIDLE -ge 5*60*1000 ]]; then
    echo "${NAME} v${VERSION}: User idle time was more than 5 minutes.  continuing..."
    if [ $UPTIME -ge $REBOOT_HOURS ]; then
      echo "${NAME} v${VERSION}: running /sbin/reboot"
      # /sbin/reboot
    else
      echo "${NAME} v${VERSION}: running /sbin/get_rmsettings"
      # /sbin/get_rmsettings
    fi
  else
    echo "${NAME} v${VERSION}: User idle time was less than 5 minutes.  exiting..."
  fi
else
  echo "${NAME} v${VERSION}: Citrix (wfica) found running.  exiting..."
fi
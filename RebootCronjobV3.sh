#IGEL Kiosk Reboot Script v3
#!/bin/bash
REBOOT_HOURS=720
MAXIMUM_DELAY_HOURS=2
MAXIMUM_SLEEP_SECONDS=$(($MAXIMUM_DELAY_HOURS * 3600))
UPTIME=`/usr/bin/printf %.0f $(/usr/bin/awk '{print $0/3600;}' /proc/uptime)`
SLEEP_TIME=$((1 + RANDOM % $MAXIMUM_SLEEP_SECONDS))
/bin/sleep $SLEEP_TIME
if ! /usr/bin/pgrep -f wfica > /dev/null; then #Check that Citrix Workspace is NOT running.
    if [ $UPTIME -ge $REBOOT_HOURS ]; then
        /sbin/reboot
    else
        /sbin/get_rmsettings
    fi
fi 
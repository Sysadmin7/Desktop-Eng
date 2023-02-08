#Not for IGEL Implementation without testing.
#Script checks that the Citrix process is NOT running. Will reboot the machine if IDLE for 30 days.
#For questions, Brandon btoddr22@outlook.com
#!/bin/bash
REBOOT_HOURS=720
MAXIMUM_DELAY_HOURS=2
MAXIMUM_SLEEP_SECONDS=$(($MAXIMUM_DELAY_HOURS * 3600))
UPTIME=`/usr/bin/printf %.0f $(/usr/bin/awk '{print $0/3600;}' /proc/uptime)`
SLEEP_TIME=$((1 + RANDOM % $MAXIMUM_SLEEP_SECONDS))
/bin/sleep $SLEEP_TIME
if /usr/bin/pgrep -f wfica > /dev/null; then
    if [ $UPTIME -ge $REBOOT_HOURS ]; then
        /sbin/reboot
    else
        /sbin/get_rmsettings
    fi
fi
#!/bin/bash

# Must be run as root. It sets the ESSID and nickname of the wireless interface to a string that is unlikely to be used as an actual network name.
# effectively preventing the device from connecting to the "KaleidaWiFi" network.
# Script is not fully funtional. Still in development and testing.

# Set the SSID of the network you want to block
ssid="KaleidaWiFi"

# Get the interface name of the wireless device
interface=$(iw dev | awk '$1=="Interface"{print $2}')

# Check if the wireless device is connected to the network to be blocked
if iw dev "${interface}" link | grep -q "${ssid}"; then
  # Disconnect from the network
  nmcli device disconnect "${interface}"
fi

# Block connections to the network
iw dev "${interface}" set power_save off
iwconfig "${interface}" essid "${ssid}" nick "${ssid}" mode managed power off
echo "Blocked connections to ${ssid}."

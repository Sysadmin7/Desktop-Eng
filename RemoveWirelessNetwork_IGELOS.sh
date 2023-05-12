#!/bin/bash

# Script is intended for use with IGEL OS.
# Brandon Todd - btoddr22@outlook.com

# Set the name of the network you want to remove
network_name="NetworkNameHere"

# Get the UUID of the network configuration, if it exists
uuid=$(nmcli connection show | grep "${network_name}" | awk '{print $2}')

# If a UUID was found, delete the network configuration
if [[ -n "${uuid}" ]]; then
  nmcli connection delete "${uuid}"
  echo "Deleted network configuration for ${network_name}."
else
  echo "No network configuration found for ${network_name}."
fi

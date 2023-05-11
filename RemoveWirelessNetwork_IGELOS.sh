#!/bin/bash
# Set the network_name variable to the name of the wireless network you want to remove.
# Use the nmcli connection show command to display a list of network connections.
# Use grep and awk to find the UUID of the network configuration that matches the specified name.
# nmcli is intended for use with IGEL OS, NOT tested, NOT implemented
# Brandon Todd - btoddr22@outlook.com

# Set the name of the network you want to remove
network_name="My Network"

# Get the UUID of the network configuration
uuid=$(nmcli connection show | grep "${network_name}" | awk '{print $2}')

# Remove the network configuration
nmcli connection delete "${uuid}"

#!bin/bash
# Read setup.ini from IGEL device and remove saved configured interface settings for KaleidaWifi.
# WARNING: Script WILL reboot endpoint and force connection from UMS wifi profile.
# Brandon Todd - btoddr22@outlook.com

if grep -i "network_name=<KaleidaWiFi>" /wfs/setup.ini; then
  resetvalue_tree network.interfaces.wirelesslan; killwait_postsetupd; write_rmsettings;
  /sbin/reboot;
fi

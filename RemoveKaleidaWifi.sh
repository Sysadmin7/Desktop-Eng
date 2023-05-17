#!bin/bash
# Read setup.ini from IGEL device and remove saved configured interface settings for KaleidaWifi
# Brandon Todd - btoddr22@outlook.com

if grep -i "network_name=<KaleidaWiFi>" /wfs/setup.ini; then
  resetvalue_tree network.interfaces.wirelesslan; killwait_postsetupd; write_rmsettings;
  /sbin/reboot;
fi
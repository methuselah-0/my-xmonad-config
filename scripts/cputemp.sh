#!/bin/bash
if [[ -f /sys/devices/platform/coretemp.0/hwmon/hwmon1/temp2_input ]] ; then
    temp1="$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon1/temp2_input)"
elif [[ -f /sys/devices/platform/coretemp.0/hwmon/hwmon2/temp2_input ]] ; then
    temp1="$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon2/temp2_input)"
elif [[ -f /sys/devices/platform/coretemp.0/hwmon/hwmon0/temp1_input ]] ; then
    temp1="$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon0/temp1_input)"
fi
expr "$temp1" / 1000


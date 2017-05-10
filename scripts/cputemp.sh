#!/bin/bash
temp1=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon2/temp2_input)
expr "$temp1" / 1000

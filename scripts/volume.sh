#!/bin/bash
#str=`amixer sget Master`
#str1=${str#Simple*\[}
#v1=${str1%%]*}
#echo $v1
vol=""
for i in {0..5} ; do
    if pamixer --get-volume --sink $i 1>/dev/null ; then
	vol+="$(pamixer --get-volume --sink $i)% * "
    fi
done
printf '%s' "${vol%\ \*\ }"

#printf '%s' "$(amixer sget Master | grep -Eo "[0-9]{1,3}%")" 

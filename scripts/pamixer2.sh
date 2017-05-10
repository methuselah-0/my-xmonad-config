#!/bin/bash
sink=""
for i in {1..10} ; do
    if pamixer --get-volume --sink $i 1>/dev/null ; then
	sink+=$i
    fi
done
case $1 in
    "-t") pamixer --sink $sink -t ;;
    "-i") pamixer --sink $sink -i $2 ;;
    "-d") pamixer --sink $sink -d $2 ;;
    *) echo '%s' "pamixer2 needs arg"
esac

		

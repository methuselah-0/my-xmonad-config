#!/run/current-system/profile/bin/bash

source ~/.xmonad/scripts/color_vars.sh
source ~/.xmonad/scripts/segments.sh

pipe_to_dzen() {
    # endless loop
    while true; do
        local soundlevel=$(amixer sget Master | grep -Eo "[0-9]{1,3}%")
        echo "^fg($colLightGreenA400) Vol: $soundlevel | $(mpc current)"
        sleep 1
    done
}

xpos=0
ypos=0
width=427
height=16
fgcolor="#ffffff" # black
bgcolor="#000000"
#font="-*-fixed-medium-*-*-*-12-*-*-*-*-*-*-*"
font="xft:terminus:size=10"
parameters="  -x $xpos -y $ypos -w $width -h $height"
parameters+=" -fn $font"
parameters+=" -ta c -bg $bgcolor -fg $fgcolor"
parameters+=" -title-name dzentop"

pipe_to_dzen | dzen2 $parameters &

pipe_to_dzen2() {
    # endless loop
    while true; do
        echo "^fg($colLightGreenA400) $(date +'%a %b %d %H:%M:%S')"
        sleep 1
    done
}

xpos2=427
ypos2=0
width2=427
height2=16
fgcolor2="#ffffff"
bgcolor2="#000000"
font2="xft:terminus:size=10"
parameters2="  -x $xpos2 -y $ypos2 -w $width2 -h $height2"
parameters2+=" -fn $font2"
parameters2+=" -ta c -bg $bgcolor2 -fg $fgcolor2"
parameters2+=" -title-name dzentop2"

pipe_to_dzen2 | dzen2 $parameters2 &

pipe_to_dzen3() {
    # endless loop
    while true; do
        setCPU
        setNet
	setBattery
	setTemp
        echo "^fg($colLightGreenA400) $segmentNet" \
	     "^fg($colLightGreenA400) $segmentCPU" \
	     "^fg($colLightGreenA400) $segmentTemp" \
	     "^fg($colLightGreenA400) $segmentBattery"
        sleep 1
    done
}

xpos3=854
ypos3=0
width3=426
height3=16
fgcolor3="#ffffff"
bgcolor3="#000000"
font3="xft:terminus:size=10"
parameters3="  -x $xpos3 -y $ypos3 -w $width3 -h $height3"
parameters3+=" -fn $font3"
parameters3+=" -ta c -bg $bgcolor3 -fg $fgcolor3"
parameters3+=" -title-name dzentop3"

pipe_to_dzen3 | dzen2 $parameters3

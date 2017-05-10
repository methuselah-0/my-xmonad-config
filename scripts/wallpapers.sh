#!/bin/bash

# source: https://abz89.wordpress.com/2009/05/05/quick-reference-use-xwinwrap-to-bring-a-dreamscene-to-your-linux-desktop/

#Example xwinwrap commands line to use a video as our dreamscene:

#xwinwrap -ni -o 0.6 -fs -s -st -sp -b -nf -- mplayer -wid WID -quiet "~/.xmonad/wallpapers/SYNTHWAVE - Dark Gaming Mix (80 minutes - 2016)-nomNAAMDReE.mkv"

#note: You may add -nosound line to run a video without sound.

# Example xwinwrap commands line to use a screensaver as our dreamscene:

xwinwrap -ni -argb -fs -s -st -sp -a -nf -- /usr/lib/misc/xscreensaver/glmatrix -root -window-id WID

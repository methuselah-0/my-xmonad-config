This repo is a mirror of my xmonad setup running on two different systems:
  * libreboot X200 with Parabola GNU/Linux
  * Devuan GNU/Linux

It has a green Matrix theme configured with:
  * green-colored dmenu
  * 2 green-colored xmobar
  * live glmatrix xscreensaver as background
  * Compton for nice shadow-effects and compositing.
  * Many useful shortcuts and defaults, see xmonad.hs

License: GPLv3

# Screenshot
![methuselah-0 xmonad screenshot](https://github.com/methuselah-0/my-xmonad-config/blob/master/screenshot.png)

# Installation Devuan
Download this repo to ~/.xmonad

    cd && git clone https://github.com/methuselah-0/my-xmonad-config .xmonad
    cd .xmonad && ./install-devuan.sh

# Installation Parabola
For best functionality, install the following dependencies:
  * xmonad, xmonad-contrib, xmobar, trayer 
  * xscreensaver, compton, trayer, xwinwrap
  * xset, xsetroot, xbacklight, xdotool
  * unclutter
  * urxvt
  * alock
  * amixer, pamixer

Download this repo to ~/.xmonad

    cd && git clone https://github.com/methuselah-0/my-xmonad-config .xmonad

Also, urxvt transparency is enabled. For more info see ~/.Xdefaults and https://wiki.haskell.org/Xmonad/Frequently_asked_questions

Make sure to add the following to /etc/X11/xorg.conf:

    Section "Extensions"
      Option "Composite" "enable"
    EndSection

and move the .Xdefaults file to ~/.Xdefaults which should contain:

    URxvt*transparent: false ! needs not be true.
    URxvt*fading:      0 ! the less the brighter
    URxvt*shading:     100 !the less the darker
    !URxvt.fadeColor:   [0]black
    URxvt.depth:       32
    URxvt*background:  rgba:0000/0000/0000/cccc
    
And finally, add "exec xmonad" at the end of your ~/.xinitrc or replace whatever you had there before as your final exec statement (create ~/.xinitrc if necessary).

Now you can start xmonad with startx after a console login.


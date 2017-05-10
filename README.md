This is my xmonad setup running on a libreboot X200 with Parabola GNU/Linux.

License: GPLv3

For best functionality, install the following dependencies:
  * xmonad, xmonad-contrib, xmobar, trayer 
  * xscreensaver, xcompmgr, trayer, xwinwrap
  * xset, xsetroot, xbacklight, xdotool
  * unclutter
  * urxvt
  * alock
  * amixer, pamixer

# INSTALLATION
    cd && git clone <this url>

Also, urxvt transparency is enabled. For more info see ~/.Xdefaults and https://wiki.haskell.org/Xmonad/Frequently_asked_questions

Make sure to add the following to /etc/X11/xorg.conf:
    Section "Extensions"
      Option "Composite" "enable"
    EndSection

and move .Xdefaults to ~/.Xdefaults which should contain:

    URxvt*transparent: false ! needs not be true.
    URxvt*fading:      0 ! the less the brighter
    URxvt*shading:     100 !the less the darker
    !URxvt.fadeColor:   [0]black
    URxvt.depth:       32
    URxvt*background:  rgba:0000/0000/0000/cccc
    
And finally, add "exec xmonad" at the end of your ~/.xinitrc or replace whatever you had there before as your final exec statement.

Now you can start xmonad with startx after a console login.


# Execute all initialization scripts from the default scripts folder -from archlinux wiki.  
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Loading ~./Xmodmap from here only works if Xserver has finished initializing, which it won't have. Adjust sleep seconds accordingly.

#sh -c "sleep 7; xmodmap ~/.Xmodmap" </dev/null >/dev/null 2>&1 &

#set bell-style none
#setterm -blength 0 (for console, put in console startupscript if wanted)

# Start xmonad.
# exec is used to replace this shell script's process.
# Note that everything relying on Xserver to be finished initializing
# should be started with delay option: sh -c "sleep X; .."

#exec awesome
#exec xmonad
#exec xfce4-session
#exec enlightenment_start

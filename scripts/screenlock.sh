
main(){
#if true ; then
    # Toggle xmobar visibility
    xdotool key super+v # maximize screen    
    xdotool key super+alt+b
    sleep 0.2
    
    # Disable VT-switching
    setxkbmap -option srvrkeys:none

    # The xscreensaver blanking hangs the cmatrix program thus we provide fake user activity.
    blankprotect(){
	sleep 3
	while pgrep alock ; do xscreensaver-command -deactivate && sleep 5 ; done
	pkill cmatrix
    }
    blankprotect &

    # Lock and start cmatrix
    sudo -HPE -u user1 /bin/bash -c alock -auth pam -b none -c blank & urxvt -e cmatrix
    
    # Reset
    xdotool key super+b
    xdotool key super+v
    sudo -HPE -u user1 setxkbmap -option ''
    xmodmap /home/user1/.Xmodmap &
}
usage(){
cat <<EOF > /dev/stdout
      * * * * * DISPLAY=0.0 screenlock.sh 
    in crontab, or:

    screenlock.sh OPTION
      -f --force , example: screenlock.sh -f
EOF
}

if !(pgrep alock) && xscreensaver-command -time | grep -q 'screen blanked' ; then
    main
elif [[ "$1" == "--force" ]] || [[ "$1" == "-f" ]] ; then
    main
elif [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]] ; then
    usage
fi


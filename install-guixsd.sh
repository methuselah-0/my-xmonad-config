#!/run/current-system/profile/bin/bash
f_do_Dependencies(){
    # user needs to install gcc-toolchain to compile with libxft
    guix package -i gcc-toolchain
    export PATH="~/.guix-profile/bin:/home/user1/.guix-profile/sbin${PATH:+:}$PATH"
    export C_INCLUDE_PATH="~/.guix-profile/include${C_INCLUDE_PATH:+:}$C_INCLUDE_PATH"
    export CPLUS_INCLUDE_PATH="~/.guix-profile/include${CPLUS_INCLUDE_PATH:+:}$CPLUS_INCLUDE_PATH"
    export LIBRARY_PATH="~/.guix-profile/lib${LIBRARY_PATH:+:}$LIBRARY_PATH"
    # xdg-utils etc.
}
f_do_Terminal_And_Fonts(){
    ln -fs ~/.xmonad/.Xdefaults ~/.Xdefaults
    ln -fs ~/.xmonad/.Xmodmap ~/.Xmodmap
}
f_do_Wallpaper_And_Screenlock(){ # git clone https://github.com/lrewega/xwinwrap
    cat /home/${username}/.xmonad/scripts/screenlock.sh.in | awk -v myuser="${username}" '{ sub(/user1/, myuser); print }' > /home/${username}/.xmonad/scripts/screenlock.sh
    ln -s -i /home/"$username"/.xmonad/scripts/screenlock.sh /home/"$username"/bin/
    
    cd /home/"$username"/.xmonad/xwinwrap && make && make install
    if [[ ! -f /home/"$username"/.xmonad/xwinwrap ]] ; then
	ln -s -i /home/"$username"/.xmonad/xwinwrap/xwinwrap /home/"$username"/bin/xwinwrap
    fi
    pacman -S --noconfirm xscreensaver
    # todo
    # sed -i.bak '/mode/s/mode.*/mode:\tblank/' /home/${username}/.xscreensaver
    # sed -i.bak '/lock/s/lock.*/lock:\tfalse/' /home/${username}/.xscreensaver
    # sed -i.bak '/timeout/s/timeout.*/timeout:\t00:15:00/' /home/${username}/.xscreensaver
}

f_do_Alock(){ # git clone https://github.com/Arkq/alock
    cd /home/"$username"/.xmonad/alock && autoreconf --install && ./configure --enable-pam --enable-hash --enable-xrender --enable-imlib2 --with-dunst --with-xbacklight && make && make install
}

f_do_Start_Screensaver-Checking(){
    sudo -u "$username" crontab -l > /tmp/crontab.tmp
    sudo -u "$username" crontab -l > /tmp/crontab.bak # for backup
    printf '%s\n' "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/$username/bin" >> /tmp/crontab.tmp
    printf '%s\n' "* * * * * screenlock.sh" >> /tmp/crontab.tmp
    sudo -u "$username" crontab /tmp/crontab.tmp
    rm /tmp/crontab.tmp
    export PATH="${PATH}":/home/"$username"/bin && printf '%s' 'export PATH="${PATH}":~/bin' >> /home/"$username"/.bashrc
}

f_do_Mpd-Related(){
    mkdir -p /home/${username}/Music && cp ./example_music/01.\ Colliding\ Lights.flac /home/${username}/Music/
    chown "${username}":"${username}" /home/${username}/Music/
    mkdir -p /home/$username/.mpd
cat <<EOF > /home/${username}/.mpd/mpd.conf
music_directory "/home/${username}/Music"
db_file      "/home/${username}/.mpd/mpd.db"  
log_file      "/home/${username}/.mpd/mpd.log"  
pid_file      "/home/${username}/.mpd/mpd.pid"  
state_file     "/home/${username}/.mpd/mpdstate"  
audio_output {  
#    type "PULSE"
    type  "alsa"  
    name  "MPD"  
}  
mixer_type "software"
EOF
    ln -s -i /home/${username}/.mpd/mpd.conf /home/${username}/mpdconf
    chown -R "$username":"$usergroup" /home/${username}/.xmonad
    chown -R "$username":"$usergroup" /home/${username}/.mpd
    mpc update
    # fix pulseaudio under openrc (still won't fix using pamixer)
    # source: https://forum.manjaro.org/t/pulseaudio-and-openrc/5881/3
    pacman -S pulseaudio pulseaudio-alsa pamixer pavucontrol
    sed -i.bak 's/autospawn/#autospawn/g' /etc/pulse/client.conf
}
main(){
    username=$1
    usergroup=$1
    if [[ -n $2 ]] ; then
	usergroup=$2
    fi
    f_do_Dependencies
    f_do_Terminal_And_Fonts
    f_do_Wallpaper_And_Screenlock
    f_do_Alock
    f_do_Start_Screensaver-Checking
    f_do_Mpd-Related
    chown -R ${username}:${usergroup} /home/${username}/.xmonad
}
#if [[ $(id -u) -ne 0 ]] ; then echo 'Please run me as root or "sudo ./install-devuan.sh <username>"' ; exit 1 ; fi
if [[ -z $1 ]]
then
    echo "Run this script with ./install-guixsd.sh <user> [group]"
    exit 1
elif ! ( which libgcrypt >/dev/null 2>/dev/null ) || ! (which linux-pam >/dev/null 2>/dev/null)
then
    echo "make sure to install libgcrypt and linux-pam first"
    exit 1
else
    main $@
fi

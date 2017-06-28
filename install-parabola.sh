#!/bin/bash
f_do_Dependencies(){
    pacman -S --noconfirm make automake autoconf xorg-xbacklight dunst xorg imlib2 libgcrypt libxrender libxxf86misc pam xmlto libxcursor pkg-config terminus-font pamixer pulseaudio pulseaudio-alsa alsa-lib alsa-tools alsa-utils alsa-plugins mpd mpc ncmpcpp # xorg for alock, automake needed for aclocal error of alock build. autoconf has autoreconf which is needed for alock build, xorg-xbackligt and dunst are also for alock
    mkdir -p /home/"$username"/bin
    chown "${username}":"${username}" /home/"$username"/bin
}

f_do_Xmonad(){
    pacman -S --noconfirm xmonad xmonad-contrib xmobar trayer dmenu unclutter feh imagemagick compton cmatrix xdotool
    cat /home/${username}/.xmonad/scripts/screenlock.sh.in | awk -v myuser="${username}" '{ sub(/user1/, myuser); print }' > /home/${username}/.xmonad/scripts/screenlock.sh
    ln -s -i /home/"$username"/.xmonad/scripts/screenlock.sh /home/"$username"/bin/
}

f_do_Terminal_And_Fonts(){
    pacman -S --noconfirm $(pacman -Ssq ttf-) rxvt-unicode
    unp /home/"$username"/.xmonad/"${font}"
    cd /home/"$username"/.xmonad/"${font%tar.gz}"
    ./configure --prefix=/usr
    make -j4
    make install fontdir
    ln -s -i /home/"$username"/.xmonad/.Xdefaults /home/"$username"/.Xdefaults
    ln -s -i /home/"$username"/.xmonad/.Xmodmap /home/"$username"/.Xmodmap
}

f_do_Wallpaper_And_Screenlock(){ # git clone https://github.com/lrewega/xwinwrap
    cd /home/"$username"/.xmonad/xwinwrap && make && make install
    if [[ ! -f /home/"$username"/.xmonad/xwinwrap ]] ; then
	ln -s -i /home/"$username"/.xmonad/xwinwrap/xwinwrap /home/"$username"/bin/xwinwrap
    fi
    pacman -S --noconfirm xscreensaver 
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
}
main(){
    username=$1
    usergroup=$1
    font="terminus-font-4.46.tar.gz"
    if [[ -n $2 ]] ; then
	usergroup=$2
    fi
    f_do_Dependencies
    f_do_Xmonad
    f_do_Terminal_And_Fonts
    f_do_Wallpaper_And_Screenlock
    f_do_Alock
    f_do_Start_Screensaver-Checking
    f_do_Mpd-Related
    chown -R ${username}:${username} /home/${username}/.xmonad
}
if [[ $(id -u) -ne 0 ]] ; then echo 'Please run me as root or "sudo ./install-devuan.sh <username>"' ; exit 1 ; fi
if [[ -z $1 ]] ; then echo "Run this script with the username for which to install xmonad as first argument." ; exit 1 ; fi
main $@

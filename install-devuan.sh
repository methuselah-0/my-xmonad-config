#!/bin/bash

# Copyright license: GPLv3
# David Larsson

if [[ $(id -u) -ne 0 ]] ; then echo 'Please run me as root or "sudo ./install-devuan.sh <username>"' ; exit 1 ; fi
if [[ -z $1 ]] ; then echo "Run this script with the username for which to install xmonad as first argument." ; fi
username=$1
usergroup=$1
if [[ -n $2 ]] ; then
    usergroup=$2
fi

# dependencies
echo "not installing dependencies.."
apt-get update && apt-get upgrade
apt-get install -y git dh-autoreconf libgcrypt20-dev libimlib2-dev libpam0g-dev mcron xserver-xorg xinit
apt-get install -y  pulseaudio pavucontrol alsa-tools alsa-utils mpd mpc ncmpcpp libalsaplayer0 pavucontrol gstreamer0.10-alsa gstreamer0.10-plugins-base sudo

mkdir -p /home/"$username"/bin
chown "${username}":"${username}" /home/"$username"/bin

# xmonad
apt-get install -y xmonad libghc-xmonad-prof dmenu xmobar trayer unclutter feh imagemagick compton cmatrix cmatrix-xfont xdotool
cat /home/${username}/.xmonad/scripts/screenlock.sh.in | awk -v myuser="${username}" '{ sub(/user1/, myuser); print }' 
ln -s /home/"$username"/.xmonad/scripts/screenlock.sh /home/"$username"/bin/screenlock.sh

# terminal and fonts
#apt-get install -y xfonts-* ttf-* rxvt-unicode
ln -s -i /home/"$username"/.xmonad/.Xdefaults /home/"$username"/.Xdefaults
ln -s -i /home/"$username"/.xmonad/.Xmodmap /home/"$username"/.Xmodmap

# wallpaper and screenlock, git clone https://github.com/lrewega/xwinwrap
ln -s -i /home/"$username"/.xmonad/xwinwrap/xwinwrap /home/"$username"/bin/xwinwrap
cd /home/"$username"/.xmonad/xwinwrap && make && make install
apt-get install -y xscreensaver xscreensaver-gl xscreensaver-gl-extra xss-lock

# alock, git clone https://github.com/Arkq/alock
#ln -s /home/"$username"/.xmonad/alock/alock /home/"$username"/bin/alock
cd /home/"$username"/.xmonad/alock && autoreconf --install && ./configure --enable-pam --enable-hash --enable-xrender --enable-imlib2 --with-dunst --with-xbacklight && make && make install

# start screensaver-checking
sudo -u "$username" crontab -l > /tmp/crontab.tmp
sudo -u "$username" crontab -l > /tmp/crontab.bak # for backup
printf '%s\n' "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/$username/bin" >> /tmp/crontab.tmp
printf '%s\n' "* * * * * DISPLAY=:0 screenlock.sh" >> /tmp/crontab.tmp
sudo -u "$username" crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp
export PATH="${PATH}":/home/"$username"/bin && printf '%s' 'export PATH="${PATH}":~/bin' >> /home/"$username"/.bashrc

f_do_Terminal_And_Fonts(){
    unp /home/"$username"/.xmonad/"${font}"
    cd /home/"$username"/.xmonad/"${font%tar.gz}"
    ./configure --prefix=/usr
    make -j4
    make install fontdir
    ln -s -i /home/"$username"/.xmonad/.Xdefaults /home/"$username"/.Xdefaults
    ln -s -i /home/"$username"/.xmonad/.Xmodmap /home/"$username"/.Xmodmap
}
f_do_Terminal_And_Fonts

# mpd-related
mkdir -p /home/${username}/Music && cp /home${username}/example_music/01.\ Colliding\ Lights.flac /home/${username}/Music/
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
ln -s /home/${username}/.mpd/mpd.conf /home/${username}/mpdconf
chown -R "$username":"$usergroup" /home/${username}/.xmonad
chown -R "$username":"$usergroup" /home/${username}/.mpd
mpc update

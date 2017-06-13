#!/bin/bash
if [[ $(id -u) -ne 0 ]] ; then echo 'Please run me as root or "sudo ./install-devuan.sh"' ; exit 1 ; fi
read -p "Your username? "
username=$REPLY
usergroup=$REPLY
read -p "Your user group? (leave empty for same as user) "
if [[ -n $REPLY ]] ; then
    usergroup=$REPLY
fi

# dependencies
echo "not installing dependencies.."
apt-get install -y git dh-autoreconf libgcrypt20-dev libimlib2-dev libpam0g-dev echo

cd /home/"$username" && mkdir -p /home/"$username"/bin

# xmonad
apt-get install -y xmonad libghc-xmonad-prof dmenu xmobar trayer unclutter feh imagemagick compton cmatrix cmatrix-xfont xdotool
chown -R "$username":"$usergroup" .xmonad
ln -s /home/"$username"/.xmonad/scripts/screenlock.sh /home/"$username"/bin/
chown -R "$username":"$usergroup" /home/"$username"/bin/screenlock.sh

# terminal and fonts
apt-get install -y xfonts-* ttf-* rxvt-unicode
ln -s /home/"$username"/.xmonad/.Xdefaults /home/"$username"/.Xdefaults

# wallpaper and screenlock
cd /home/"$username"/bin && git clone https://github.com/lrewega/xwinwrap && cd xwinwrap && make && make install
apt-get install -y xscreensaver xscreensaver-gl xscreensaver-gl-extra xss-lock mcron
# alock
cd /home/"$username"/bin && git clone https://github.com/Arkq/alock && cd alock && autoreconf --install && ./configure --enable-pam --enable-hash --enable-xrender --enable-imlib2 --with-dunst --with-xbacklight && make

# start screensaver-checking
crontab -l > /tmp/crontab.tmp
crontab -l > /tmp/crontab.bak # for backup
printf '%s\n' "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/$username/bin" >> /tmp/crontab.tmp
printf '%s\n' "* * * * * screenlock.sh" >> /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp

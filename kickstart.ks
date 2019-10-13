# Configure installation method
url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-30&arch=x86_64"
repo --name=updates
repo --name=rpmfusion-free --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-30&arch=x86_64" --includepkgs=rpmfusion-free-release
repo --name=rpmfusion-free-updates --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-30&arch=x86_64" --cost=0
repo --name=rpmfusion-nonfree --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-30&arch=x86_64" --includepkgs=rpmfusion-nonfree-release
repo --name=rpmfusion-nonfree-updates --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-30&arch=x86_64" --cost=0
text

# User
%include /tmp/user.ks

# System timezone
timezone Asia/Jerusalem

# Disk
#ignoredisk --only-use=nvme0n1
clearpart --all --initlabel # --drives=nvme0n1
autopart --encrypted --type lvm --nohome
bootloader --location=mbr # --boot-drive=nvme0n1

# Keyboard
keyboard --vckeymap=us --xlayouts='us','il' --switch=grp:alt_shift_toggle,grp:caps_toggle

# System language
lang en_US.UTF-8

# Network information
#network  --bootproto=dhcp --device=enp0s31f6 --ipv6=auto --activate --onboot ONBOOT --essid=DS_5
#network  --hostname=somdoron.localdomain

# Sysem services
services --enabled="chronyd"

# Package Selection
%packages
@core
@standard
@fonts
@hardware-support
@networkmanager-submodules
git
autoconf
automake
make
flex
bison
gcc
gcc-c++
gdb
glibc-devel
gdb
libtool
make
pkgconfig
valgrind
cmake
meson
ninja-build
libsodium-devel
gnutls-devel
docker
vim
openssh
rxvt-unicode
chromium
zip
unzip
alsa-plugins-pulseaudio
pulseaudio
pulseaudio-module-bluetooth
pulseaudio-module-x11
pulseaudio-utils
pavucontrol
pantheon-agent-polkit
elementary-calculator
elementary-code
elementary-files
elementary-sound-theme
elementary-icon-theme
elementary-theme
elementary-wallpapers
elementary-terminal
chrony
wayland-devel
wayland-protocols-devel
mesa-libEGL-devel
mesa-libGLES-devel
mesa-libgbm-devel
libdrm-devel
libinput-devel
libxkbcommon-devel
systemd-devel
libcap-devel
libxcb-devel
xcb-util-image-devel
libX11-devel
pixman-devel
xorg-x11-server-Xwayland
pcre-devel
json-c-devel
pango-devel
cairo-devel
gdk-pixbuf2-devel
libevdev-devel
pam-devel
freerdp1.2-devel
libwinpr-devel
scdoc
dmenu
mercurial
light
#gtk3-devel
#libjpeg-turbo-devel
chromium-libs-media-freeworld
ffmpeg-devel
open-sans-fonts
%end

%pre --interpreter=/usr/bin/bash
exec < /dev/tty6 > /dev/tty6 2> /dev/tty6
chvt 6

read -s -p "Enter root password:" ROOT_PASSWORD
echo
read -s -p "Enter somdoron password:" PASSWORD
echo
sleep 1

echo "user --groups=wheel --name=somdoron --password=$PASSWORD
rootpw $ROOT_PASSWORD" > /tmp/user.ks

chvt 1
exec < /dev/tty1 > /dev/tty1 2> /dev/tty1
%end

%post --logfile=/tmp/post.log --interpreter=/usr/bin/bash
exec < /dev/tty6 > /dev/tty6 2> /dev/tty6
chvt 6

echo
echo "################################"
echo "# Running Post Script          #"
echo "################################"
echo

# install mono and nodejs
curl https://download.mono-project.com/repo/centos8-stable.repo | tee /etc/yum.repos.d/mono-centos8-stable.repo
curl -sL https://rpm.nodesource.com/setup_12.x | bash -
dnf -y update
dnf -y install nodejs mono-devel

# start compiling packages
mkdir -p /tmp/swaywm
pushd /tmp/swaywm

# wlroots 

git clone --branch 0.8.1 https://github.com/swaywm/wlroots.git
cd wlroots
meson --prefix /usr build 
ninja -C build
ninja -C build install
cd ..
git clone --branch 1.2 https://github.com/swaywm/sway.git
cd sway
meson --prefix /usr build
ninja -C build
ninja -C build install
cd ..

# sway
git clone --branch 1.5 https://github.com/swaywm/swayidle.git
cd swayidle
meson --prefix /usr build
ninja -C build
ninja -C build install
cd ..

# swaylock
git clone --branch 1.4 https://github.com/swaywm/swaylock.git
cd swaylock
meson --prefix /usr build
ninja -C build
ninja -C build install
cd ..

# swaybg
git clone --branch 1.0 https://github.com/swaywm/swaybg.git
cd swaybg
meson --prefix /usr build
ninja -C build
ninja -C build install
cd ..

# grim
dnf -y install libjpeg-turbo-devel
git clone --branch v1.2.0 https://github.com/emersion/grim.git
cd grim
meson --prefix /usr build
ninja -C build
ninja -C build install
cd ..

# wofi
dnf -y install gtk3-devel 
hg clone https://hg.sr.ht/~scoopta/wofi
cd wofi/Release
make
cp wofi /usr/bin

# done with compilation
popd

#vimrc configuration
echo "set exrc
set secure
set tabstop=4
set shiftwidth=4
set expandtab" > /home/somdoron/.vimrc
chown somdoron /home/somdoron/.vimrc

# ssh configuration
mkdir -p /home/somdoron/.ssh
echo "AddKeysToAgent yes" > /home/somdoron/.ssh/config
chown -R somdoron /home/somdoron/.ssh

# bash profile
echo "if [[ -z \$WAYLAND_DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]]; then exec 
    eval \$(ssh-agent)
    export _JAVA_AWT_WM_NONREPARENTING=1 
	exec sway
	exit 0
fi

if [ -z "\$SSH_AUTH_SOCK" ] ; then
	eval \$(ssh-agent)
fi
" >> /home/somdoron/.bash_profile

# default sway config
mkdir -p /home/somdoron/.config/sway
cp /etc/sway/config /home/somdoron/.config/sway/
chown -R somdoron /home/somdoron/.config

# Autologin
mkdir -p /etc/systemd/system/getty@tty1.service.d/
echo "[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin somdoron --noclear %I $TERM" > /etc/systemd/system/getty@tty1.service.d/override.conf

# Enable pulse audio switch on connect
echo "
# automatically switch to newly-connected devices
load-module module-switch-on-connect
" >> /etc/pulse/default.pa

# gsettings
echo "[org.gnome.desktop.interface]
cursor-theme='elementary'
document-font-name='Open Sans 10'
font-name='Open Sans 9'
gtk-theme='elementary'
icon-theme='elementary'
monospace-font-name='Monospace 10'
show-unicode-menu=false
toolbar-style='icons'

[org.gnome.desktop.sound]
theme-name='elementary'

[org.gnome.desktop.wm.preferences]
button-layout=':menu'
theme='elementary'
titlebar-font='Open Sans Bold 9'
titlebar-uses-system-font=false
" >  /usr/share/glib-2.0/schemas/20-sway.desktop.gschema.override

glib-compile-schemas /usr/share/glib-2.0/schemas

chvt 1
exec < /dev/tty1 > /dev/tty1 2> /dev/tty1

%end

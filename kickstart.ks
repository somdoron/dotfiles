# Configure installation method
url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-30&arch=x86_64"
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
libreoffice
ark
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
scdoc
%end

%pre --interpreter=/usr/bin/bash
exec < /dev/tty6 > /dev/tty6 2> /dev/tty6
chvt 6r

read -s -p "Enter root password:" ROOT_PASSWORD
read -s -p "Enter somdoron password:" PASSWORD
echo
sleep 1

echo "user --groups=wheel --name=somdoron --password=$PASSWORD
rootpw $ROOT_PASSWORD" > /tmp/user.ks

chvt 1
exec < /dev/tty1 > /dev/tty1 2> /dev/tty1
%end

%post --logfile /tmp/post.log

# install mono and nodejs
#rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
#su -c 'curl https://download.mono-project.com/repo/centos8-stable.repo | tee /etc/yum.repos.d/mono-centos8-stable.repo'
#curl -sL https://rpm.nodesource.com/setup_12.x | bash -
#dnf -q update
#dnf -q install nodejs mono-devel

# install wlroots and sway 
mkdir -p /tmp/swaywm
pushd /tmp/swaywm
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
popd
rm -rf /tmp/swaywm

#vimrc configuration
echo "set exrc
set secure
set tabstop=4
set shiftwidth=4
set expandtab" > /home/somdoron/.vimrc

# ssh
mkdir -p /home/somdoron/.ssh
echo "AddKeysToAgent yes" > /home/somdoron/.ssh/config

# bash profile
echo "if [[ -z \$WAYLAND_DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]]; then exec 
    eval \$(ssh-agent)
    export _JAVA_AWT_WM_NONREPARENTING=1 
	sway
	exit 0
fi

if [ -z "\$SSH_AUTH_SOCK" ] ; then
	eval \$(ssh-agent)
fi
" >> /home/somdoron/.bash_profile

%end

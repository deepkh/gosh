#!/bin/bash
# Copyright (c) 2020, Gary Huang, deepkh@gmail.com, https://github.com/deepkh
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

BOOTSTRAP_FILE_PATH=${GOSH_PATH}/go_bootstrap.sh
#define USER & PASSWORD in ~/.go_pre.sh
#BOOTSTRAP_DEFAULT_USER=
#BOOTSTRAP_DEFAULT_PASSWD=
DEFAULT_BIND="--bind /root --bind /home/${BOOTSTRAP_DEFAULT_USER} --bind /opt --bind /etc/resolv.conf"
DEFAULT_PKGS="software-properties-common cmake gdb nload tmux vim sudo wget curl ca-certificates xz-utils net-tools gperf help2man nfs-common nfs-kernel-server portmap cifs-utils avahi-daemon samba build-essential fakeroot automake flex texinfo autoconf bison gawk libtool libtool-bin libncurses5-dev git yasm unzip zip"
PKG_SDL2_DEV="libsdl2-dev libsdl2-gfx-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev libcurl4-openssl-dev libjansson-dev libyaml-dev"
PKG_SDL2="libsdl2-2.0 libsdl2-gfx-1.0 libsdl2-image-2.0 libsdl2-mixer-2.0 libsdl2-net-2.0 libsdl2-ttf-2.0 libcurl4 libjansson4 libyaml-0-2"
#MINGW32_GCC_PKGS="gcc-mingw-w64-i686 g++-mingw-w64-i686"
MINGW32_GCC_PKGS="gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64"

PATCH_MF="0"

_bootstrap_init_debian() {
#$1=relatively_rootfs_dir

sudo systemd-nspawn ${DEFAULT_BIND} -q -D ${GO_ROOTFS_PATH}/${1} /bin/bash << EEEOFEOF
apt-get update
apt-get install openssl
#update root passwd
echo -e "${BOOTSTRAP_DEFAULT_PASSWD}\n${BOOTSTRAP_DEFAULT_PASSWD}" | passwd root
#set locale
sudo localectl set-locale LANG=C.UTF-8
#add default user
useradd -m -d /home/${BOOTSTRAP_DEFAULT_USER} -s /bin/bash ${BOOTSTRAP_DEFAULT_USER}
echo -e "${BOOTSTRAP_DEFAULT_PASSWD}\n${BOOTSTRAP_DEFAULT_PASSWD}" | passwd ${BOOTSTRAP_DEFAULT_USER}
#install default packges
#apt-get install ${DEFAULT_PKGS} -y --no-install-recommends
#install i686-mingw
#apt-get install ${MINGW32_GCC_PKGS} -y
EEEOFEOF

#only jessie need this patch
#execute custom script after packages installed
if [ "${PATCH_MF}" = "1" ];then
sudo tar -Jxvpf /opt/backup/toolchain/mingw-w64-3.6.7-i686_x86_64-4.9.3-mf-inc-lib.tar.xz -C ${GO_ROOTFS_PATH}/${1}
fi
}

_bootstrap_cosmic_init() {
#$1=relatively_rootfs_dir

sudo systemd-nspawn ${DEFAULT_BIND} -q -D ${GO_ROOTFS_PATH}/${1} /bin/bash << EEEOFEOF

echo "# deb cdrom:[Ubuntu 18.10 _Cosmic Cuttlefish_ - Release amd64 (20181017.3)]/ cosmic main restricted

# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://tw.archive.ubuntu.com/ubuntu/ cosmic main restricted
# deb-src http://tw.archive.ubuntu.com/ubuntu/ cosmic main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://tw.archive.ubuntu.com/ubuntu/ cosmic-updates main restricted
# deb-src http://tw.archive.ubuntu.com/ubuntu/ cosmic-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://tw.archive.ubuntu.com/ubuntu/ cosmic universe
# deb-src http://tw.archive.ubuntu.com/ubuntu/ cosmic universe
deb http://tw.archive.ubuntu.com/ubuntu/ cosmic-updates universe
# deb-src http://tw.archive.ubuntu.com/ubuntu/ cosmic-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu 
## team, and may not be under a free licence. Please satisfy yourself as to 
## your rights to use the software. Also, please note that software in 
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://tw.archive.ubuntu.com/ubuntu/ cosmic multiverse
# deb-src http://tw.archive.ubuntu.com/ubuntu/ cosmic multiverse
deb http://tw.archive.ubuntu.com/ubuntu/ cosmic-updates multiverse
# deb-src http://tw.archive.ubuntu.com/ubuntu/ cosmic-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb http://tw.archive.ubuntu.com/ubuntu/ cosmic-backports main restricted universe multiverse
# deb-src http://tw.archive.ubuntu.com/ubuntu/ cosmic-backports main restricted universe multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
# deb http://archive.canonical.com/ubuntu cosmic partner
# deb-src http://archive.canonical.com/ubuntu cosmic partner

deb http://security.ubuntu.com/ubuntu cosmic-security main restricted
# deb-src http://security.ubuntu.com/ubuntu cosmic-security main restricted
deb http://security.ubuntu.com/ubuntu cosmic-security universe
# deb-src http://security.ubuntu.com/ubuntu cosmic-security universe
deb http://security.ubuntu.com/ubuntu cosmic-security multiverse
# deb-src http://security.ubuntu.com/ubuntu cosmic-security multiverse" > /etc/apt/sources.list


apt-get update
apt-get install openssl
#update root passwd
echo -e "${BOOTSTRAP_DEFAULT_PASSWD}\n${BOOTSTRAP_DEFAULT_PASSWD}" | passwd root
#add default user
useradd -m -d /home/${BOOTSTRAP_DEFAULT_USER} -s /bin/bash ${BOOTSTRAP_DEFAULT_USER}
echo -e "${BOOTSTRAP_DEFAULT_PASSWD}\n${BOOTSTRAP_DEFAULT_PASSWD}" | passwd ${BOOTSTRAP_DEFAULT_USER}
#install default packges
apt-get install ${DEFAULT_PKGS} -y --no-install-recommends
#install i686-mingw
apt-get install ${MINGW32_GCC_PKGS} -y
EEEOFEOF
}

_bootstrap_xenial_init() {
#$1=relatively_rootfs_dir

sudo systemd-nspawn ${DEFAULT_BIND} -q -D ${GO_ROOTFS_PATH}/${1} /bin/bash << EEEOFEOF

echo "# deb cdrom:[Ubuntu 18.10 _Cosmic Cuttlefish_ - Release amd64 (20181017.3)]/ cosmic main restricted

# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://tw.archive.ubuntu.com/ubuntu/ xenial main restricted
# deb-src http://tw.archive.ubuntu.com/ubuntu/ xenial main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://tw.archive.ubuntu.com/ubuntu/ xenial-updates main restricted
# deb-src http://tw.archive.ubuntu.com/ubuntu/ xenial-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://tw.archive.ubuntu.com/ubuntu/ xenial universe
# deb-src http://tw.archive.ubuntu.com/ubuntu/ xenial universe
deb http://tw.archive.ubuntu.com/ubuntu/ xenial-updates universe
# deb-src http://tw.archive.ubuntu.com/ubuntu/ xenial-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu 
## team, and may not be under a free licence. Please satisfy yourself as to 
## your rights to use the software. Also, please note that software in 
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://tw.archive.ubuntu.com/ubuntu/ xenial multiverse
# deb-src http://tw.archive.ubuntu.com/ubuntu/ xenial multiverse
deb http://tw.archive.ubuntu.com/ubuntu/ xenial-updates multiverse
# deb-src http://tw.archive.ubuntu.com/ubuntu/ xenial-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb http://tw.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
# deb-src http://tw.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
# deb http://archive.canonical.com/ubuntu xenial partner
# deb-src http://archive.canonical.com/ubuntu xenial partner

deb http://security.ubuntu.com/ubuntu xenial-security main restricted
# deb-src http://security.ubuntu.com/ubuntu xenial-security main restricted
deb http://security.ubuntu.com/ubuntu xenial-security universe
# deb-src http://security.ubuntu.com/ubuntu xenial-security universe
deb http://security.ubuntu.com/ubuntu xenial-security multiverse
# deb-src http://security.ubuntu.com/ubuntu xenial-security multiverse" > /etc/apt/sources.list


apt-get update
apt-get install openssl
#update root passwd
echo -e "${BOOTSTRAP_DEFAULT_PASSWD}\n${BOOTSTRAP_DEFAULT_PASSWD}" | passwd root
#add default user
useradd -m -d /home/${BOOTSTRAP_DEFAULT_USER} -s /bin/bash ${BOOTSTRAP_DEFAULT_USER}
echo -e "${BOOTSTRAP_DEFAULT_PASSWD}\n${BOOTSTRAP_DEFAULT_PASSWD}" | passwd ${BOOTSTRAP_DEFAULT_USER}
#install default packges
apt-get install ${DEFAULT_PKGS} -y --no-install-recommends
#install i686-mingw
apt-get install ${MINGW32_GCC_PKGS} -y
EEEOFEOF
}

_bootstrap() {
  #$1=amd64
  #$2=jessie
  #$3=remote server
  #$4=relatively_rootfs_dir

  if [ "${4}" = "" ];then
    echo '${4}' cant empty!
    return 0
    #exit;
  fi

  if [ -d "${GO_ROOTFS_PATH}/${4}" ];then
    echo ${GO_ROOTFS_PATH}/${4} already exists!
    return 0
    #exit;
  fi

  sudo debootstrap --verbose --arch ${1} ${2} ${GO_ROOTFS_PATH}/${4} ${3}
  sudo rm -rf /var/lib/machines/${4}
  sudo ln -sf ${GO_ROOTFS_PATH}/${4} /var/lib/machines
}


# Ubuntu 23.10 Mantic
# the init function are not working anymore on ubuntu 23.04
# due to the behavior of systemd-nspawn seems changed since ubuntu 23.04
# use manually commands to instead 
_bootstrap_mantic_amd64() {
  #$1=amd64
  #$2=jessie
  #$3=remote server
  #$4=relatively_rootfs_dir

  A=amd64
  B=mantic
  C=http://tw.archive.ubuntu.com/ubuntu
  D=${B}-${A}

  if [ "${D}" = "" ];then
    echo '${D}' cant empty!
    #return 0
    #exit;
  fi

  if [ -d "${GO_ROOTFS_PATH}/${D}" ];then
    echo ${GO_ROOTFS_PATH}/${D} already exists!
    #return 0
    #exit;
  fi

  sudo debootstrap --include=systemd,dbus --verbose --arch ${A} ${B} ${GO_ROOTFS_PATH}/${D} ${C}
  sudo rm -rf /var/lib/machines/${D}
  sudo ln -sf ${GO_ROOTFS_PATH}/${D} /var/lib/machines
}


# debian 12
# the init function are not working anymore on ubuntu 23.04
# due to the behavior of systemd-nspawn seems changed since ubuntu 23.04
# use manually commands to instead 
_bootstrap_bookworm_amd64() {
  #$1=amd64
  #$2=jessie
  #$3=remote server
  #$4=relatively_rootfs_dir

  A=amd64
  B=bookworm
  C=http://ftp.tw.debian.org/debian
  D=${B}-${A}

  if [ "${D}" = "" ];then
    echo '${D}' cant empty!
    #return 0
    #exit;
  fi

  if [ -d "${GO_ROOTFS_PATH}/${D}" ];then
    echo ${GO_ROOTFS_PATH}/${D} already exists!
    #return 0
    #exit;
  fi

  sudo debootstrap --include=systemd,dbus --verbose --arch ${A} ${B} ${GO_ROOTFS_PATH}/${D} ${C}
  sudo rm -rf /var/lib/machines/${D}
  sudo ln -sf ${GO_ROOTFS_PATH}/${D} /var/lib/machines
}

# debian 8
_bootstrap_jessie_amd64() {
  PATCH_MF="1"
  _bootstrap amd64 jessie "http://ftp.tw.debian.org/debian" $@ 
  _bootstrap_init_debian ${1}
}

# debian 9
_bootstrap_stretch_amd64() {
  _bootstrap amd64 stretch "http://ftp.tw.debian.org/debian" $@
  _bootstrap_init_debian ${1}
}

# Ubuntu 18.10 cosmic (but apt-cache show don't contain mingw compiler)
_bootstrap_cosmic_amd64() {
  _bootstrap amd64 cosmic "http://tw.archive.ubuntu.com/ubuntu" $@ 
  _bootstrap_cosmic_init ${1}
}

# Ubuntu 16.04 xenial (but apt-cache show don't contain mingw compiler)
_bootstrap_xenial_amd64() {
  _bootstrap amd64 xenial "http://tw.archive.ubuntu.com/ubuntu" $@ 
  _bootstrap_xenial_init ${1}
}

_bootstrap_boot() {
  #sudo systemd-nspawn -M ${1} ${DEFAULT_BIND} -bD ${GO_ROOTFS_PATH}/${1}
  # there have program of "Invalid machine name: cosmic_x64" when flag with "-M cosmic_x64" on ubuntu 20.04
  sudo systemd-nspawn ${DEFAULT_BIND} -bD ${GO_ROOTFS_PATH}/${1} 
}

#
# behavior changed, since ubuntu 23.04
# https://wiki.debian.org/nspawn
# https://serverfault.com/questions/995562/bind-mount-with-systemd-nspawn
# 
_bootstrap_edit() {

  DEFAULT_SERVICE_FILE=/lib/systemd/system/systemd-nspawn@.service
  SERVICE_FILE=/etc/systemd/system/systemd-nspawn@${1}.service

  if [ -f "${SERVICE_FILE}" ];then
    echo ${SERVICE_FILE} already exists!
  else
    sudo cp ${DEFAULT_SERVICE_FILE} ${SERVICE_FILE}
  fi

  # use the following line to instead ExecStart
  # ExecStart=systemd-nspawn --quiet --keep-unit --boot --link-journal=try-guest -U --settings=override --machine=%i --bind /opt:/opt --bind /home --bind /root --private-users=off
  sudo vim.tiny ${SERVICE_FILE}
  sudo systemctl daemon-reload
  
  #Boot when OS startup. It's depend on situation.
  #sudo systemctl enable systemd-nspawn@${1}.service
}

_bootstrap_start() {
  sudo systemctl start systemd-nspawn@${1}
}

_bootstrap_stop() {
  sudo systemctl stop systemd-nspawn@${1}
}



_bootstrap_mount() {
  sudo systemd-nspawn -bD ${GO_ROOTFS_PATH}/${1}
}

_bootstrap_login() {
  #$1=relatively_rootfs_dir
  sudo machinectl login ${1}
}

_bootstrap_chroot_umnt() {
  ROOT="$GO_ROOTFS_PATH/$1"
  sudo umount $ROOT/proc  2> /dev/null
  sudo umount $ROOT/sys 2> /dev/null
  
  sudo umount $ROOT/dev/tty 2> /dev/null
  sudo umount $ROOT/dev/pts 2> /dev/null
  sudo umount $ROOT/dev 2> /dev/null

  sudo umount $ROOT/home 2> /dev/null
  sudo umount $ROOT/root 2> /dev/null
  sudo umount $ROOT/opt 2> /dev/null

# sudo umount $ROOT/run/dbus
# sudo umount $ROOT/run/avahi-daemon
  
}

_bootstrap_chroot_mnt() {
  ROOT="$GO_ROOTFS_PATH/$1"

  sudo mount -t proc none $ROOT/proc 2> /dev/null
  sudo mount -t sysfs sys $ROOT/sys  2> /dev/null 

  sudo mount -o bind /dev $ROOT/dev 2> /dev/null
  sudo mount -o bind /dev/pts $ROOT/dev/pts 2> /dev/null
  sudo mount -o bind /dev/tty $ROOT/dev/tty 2> /dev/null

  sudo mount -o bind /opt $ROOT/opt 2> /dev/null
  sudo mount -o bind /home $ROOT/home 2> /dev/null
  sudo mount -o bind /root $ROOT/root 2> /dev/null

# sudo mount -o bind /run/dbus $ROOT/run/dbus 2> /dev/null
# sudo mount -o bind /run/avahi-daemon $ROOT/run/avahi-daemon 2> /dev/null
  
}

_bootstrap_chroot() {
  ROOT="$GO_ROOTFS_PATH/$1"
  _bootstrap_chroot_mnt $1
  sudo chroot $ROOT /bin/bash 
  _bootstrap_chroot_umnt $1
  _bootstrap_chroot_umnt $1
}

_alias() {
  alias bootstrap_mantic_amd64="source $BOOTSTRAP_FILE_PATH _bootstrap_mantic_amd64"
  alias bootstrap_bookworm_amd64="source $BOOTSTRAP_FILE_PATH _bootstrap_bookworm_amd64"
  alias bootstrap_jessie_amd64="source $BOOTSTRAP_FILE_PATH _bootstrap_jessie_amd64"
  alias bootstrap_stretch_amd64="source $BOOTSTRAP_FILE_PATH _bootstrap_stretch_amd64"
  alias bootstrap_cosmic_amd64="source $BOOTSTRAP_FILE_PATH _bootstrap_cosmic_amd64"
  alias bootstrap_xenial_amd64="source $BOOTSTRAP_FILE_PATH _bootstrap_xenial_amd64"

  alias bootstrap_boot="source $BOOTSTRAP_FILE_PATH _bootstrap_boot"
  alias bootstrap_mount="source $BOOTSTRAP_FILE_PATH _bootstrap_mount"
  alias bootstrap_login="source $BOOTSTRAP_FILE_PATH _bootstrap_login"
  
  alias bootstrap_chroot_mnt="source $BOOTSTRAP_FILE_PATH _bootstrap_chroot_mnt"
  alias bootstrap_chroot_umnt="source $BOOTSTRAP_FILE_PATH _bootstrap_chroot_umnt"
  alias bootstrap_chroot="source $BOOTSTRAP_FILE_PATH _bootstrap_chroot"
  
  alias mantic_edit="source $BOOTSTRAP_FILE_PATH _bootstrap_edit mantic-amd64"
  alias mantic_start="source $BOOTSTRAP_FILE_PATH _bootstrap_start mantic-amd64"
  alias mantic_stop="source $BOOTSTRAP_FILE_PATH _bootstrap_stop mantic-amd64"
  alias mantic_chroot="source $BOOTSTRAP_FILE_PATH _bootstrap_chroot mantic-amd64"
  alias mantic_login="source $BOOTSTRAP_FILE_PATH _bootstrap_login mantic-amd64"
  
  alias bookworm_edit="source $BOOTSTRAP_FILE_PATH _bootstrap_edit bookworm-amd64"
  alias bookworm_start="source $BOOTSTRAP_FILE_PATH _bootstrap_start bookworm-amd64"
  alias bookworm_stop="source $BOOTSTRAP_FILE_PATH _bootstrap_stop bookworm-amd64"
  alias bookworm_chroot="source $BOOTSTRAP_FILE_PATH _bootstrap_chroot bookworm-amd64"
  alias bookworm_login="source $BOOTSTRAP_FILE_PATH _bootstrap_login bookworm-amd64"
  
  alias stretch_boot="source $BOOTSTRAP_FILE_PATH _bootstrap_boot stretch"
  alias stretch_chroot="source $BOOTSTRAP_FILE_PATH _bootstrap_chroot stretch"
  alias stretch_login="source $BOOTSTRAP_FILE_PATH _bootstrap_login stretch"
  
  alias cosmic_boot="source $BOOTSTRAP_FILE_PATH _bootstrap_boot cosmic_x64"
  alias cosmic_chroot="source $BOOTSTRAP_FILE_PATH _bootstrap_chroot cosmic_x64"
  alias cosmic_login="source $BOOTSTRAP_FILE_PATH _bootstrap_login cosmic_x64"

  alias jessie2_boot="source $BOOTSTRAP_FILE_PATH _bootstrap_boot jessie2"
  alias jessie2_chroot="source $BOOTSTRAP_FILE_PATH _bootstrap_chroot jessie2"
  alias jessie2_login="source $BOOTSTRAP_FILE_PATH _bootstrap_login jessie2"
  
  alias xenial_boot="source $BOOTSTRAP_FILE_PATH _bootstrap_boot xenial_amd64"
  alias xenial_chroot="source $BOOTSTRAP_FILE_PATH _bootstrap_chroot xenial_amd64"
  alias xenial_login="source $BOOTSTRAP_FILE_PATH _bootstrap_login xenial_amd64"

  alias firefly_chroot="source $BOOTSTRAP_FILE_PATH _bootstrap_chroot firefly_20190530"

}

$@


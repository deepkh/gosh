#!/bin/bash

ROOTFS_PATH=/opt/rootfs

umnt() {
  ROOT="$ROOTFS_PATH/$1"
  sudo umount $ROOT/proc
  sudo umount $ROOT/sys
  
  sudo umount $ROOT/dev/tty
  sudo umount $ROOT/dev/pts
  sudo umount $ROOT/dev

# sudo umount $ROOT/run/dbus
# sudo umount $ROOT/run/avahi-daemon
  
# sudo umount $ROOT/opt
# sudo umount $ROOT/home/${WHOAMI}
# sudo umount $ROOT/mnt/storage
}

mnt() {
  ROOT="$ROOTFS_PATH/$1"
  umnt $1

  sudo mount -t proc none $ROOT/proc 2> /dev/null
  sudo mount -t sysfs sys $ROOT/sys  2> /dev/null 

  sudo mount -o bind /dev $ROOT/dev 2> /dev/null
  sudo mount -o bind /dev/pts $ROOT/dev/pts 2> /dev/null
  sudo mount -o bind /dev/tty $ROOT/dev/tty 2> /dev/null

# sudo mount -o bind /run/dbus $ROOT/run/dbus 2> /dev/null
# sudo mount -o bind /run/avahi-daemon $ROOT/run/avahi-daemon 2> /dev/null
  
# sudo mount -o bind /opt $ROOT/opt 2> /dev/null
# sudo mount -o bind /home/${WHOAMI} $ROOT/home/${WHOAMI} 2> /dev/null
# sudo mount -o bind /mnt/storage $ROOT/mnt/storage 2> /dev/null
}

bootstrap_1st() {
  #$1=amd64
  #$2=jessie
  #$3=remote server
  #$4=relatively_rootfs_dir

  if [ "${4}" = "" ];then
    echo '${4}' cant empty!
    return 0
    #exit;
  fi

  if [ -d "${ROOTFS_PATH}/${4}" ];then
    echo ${ROOTFS_PATH}/${4} already exists!
    #return 0
    #exit;
  fi

  sudo /usr/sbin/debootstrap --verbose --arch ${1} ${2} ${ROOTFS_PATH}/${4} ${3}
  sudo rm -rf /var/lib/machines/${4}
  sudo ln -sf ${DEBIAN_ROOTFS_PATH}/${4} /var/lib/machines
}

chroot() {
  ROOT="$ROOTFS_PATH/$1"
  mnt $1
  sudo chroot $ROOT /bin/bash -c "$2"
  umnt $1
}

chroot_exec() {
  ROOT="$ROOTFS_PATH/$1"
  sudo chroot $ROOT /bin/bash -c "$2"
  #sudo chroot $ROOT "$2"
}

bootstrap_2nd() {
  mnt $1
  chroot_exec $1 "ls /"
  chroot_exec $1 "/debootstrap/debootstrap --second-stage --verbose"
  umnt $1
}

bootstrap_cosmic_arm64_init() {
  ROOT="$ROOTFS_PATH/$1"
  echo $ROOT

cat > $ROOT/etc/apt/sources.list << EOF11
deb http://tw.ports.ubuntu.com/ubuntu-ports cosmic main restricted
deb http://tw.ports.ubuntu.com/ubuntu-ports cosmic-updates main restricted
deb-src http://tw.ports.ubuntu.com/ubuntu-ports cosmic main restricted universe multiverse
deb-src http://tw.ports.ubuntu.com/ubuntu-ports cosmic-updates main restricted universe multiverse
deb http://tw.ports.ubuntu.com/ubuntu-ports cosmic universe
deb http://tw.ports.ubuntu.com/ubuntu-ports cosmic-updates universe
deb http://tw.ports.ubuntu.com/ubuntu-ports cosmic multiverse
deb http://tw.ports.ubuntu.com/ubuntu-ports cosmic-updates multiverse
EOF11

echo "nameserver 168.95.1.1" >  $ROOT/etc/resolv.conf

cat > $ROOT/etc/profile << EOF22
# /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

if [ "$PS1" ]; then
  if [ "$BASH" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
  else
    if [ "`id -u`" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi

# The default umask is now handled by pam_umask.
# See pam_umask(8) and /etc/login.defs.

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

alias ls='ls --color=auto'
export PATH=$PATH:/sbin:/bin:/usr/bin:/usr/sbin
EOF22

chmod +x $ROOT/etc/profile 
echo "$2" > $ROOT/debootstrap/mirror

sh -c "echo ':aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7:\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff:/usr/bin/qemu-aarch64-static:' > /proc/sys/fs/binfmt_misc/register 2> /dev/null"

cp /usr/bin/qemu-aarch64-static $ROOT/usr/bin
}

# Ubuntu 18.10 cosmic aarch64
bootstrap_cosmic_arm64() {
  MIRROR="http://tw.ports.ubuntu.com"
  #init two times due to /bin/true not found
  bootstrap_1st arm64 cosmic $MIRROR $@
  bootstrap_1st arm64 cosmic $MIRROR $@ 
  bootstrap_cosmic_arm64_init $@ $MIRROR
  bootstrap_2nd $@
}

# Ubuntu 16.04 Xenial 16.04
bootstrap_xenial_amd64() {
  MIRROR="http://tw.archive.ubuntu.com/ubuntu"
  #init two times due to /bin/true not found
  bootstrap_1st amd64 xenial $MIRROR $@
  #bootstrap_1st amd64 xenial $MIRROR $@ 
  #bootstrap_xenial_amd64_init $@ $MIRROR
}


$@

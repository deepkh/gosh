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

set -e

echo ******************************************************************************************
echo !!!!!!!!!!!!!!!! NEED TO STOP ssh_chroot FIRST !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!! Enter or Ctrl+C !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo ******************************************************************************************
read

# sda is 5TB
sdb=sda
sdbs=(${sdb}2 ${sdb}3 ${sdb}4 ${sdb}5)
sdbs_size=(149999845376 149999845376 511705088 4684469239808)
sdbs_src=("/*" "/home/*" "/boot/efi/*" "/opt/*")
dst="/mnt/sdb_backup"
sdbs_dst=("${dst}/root" "${dst}/home" "${dst}/boot_efi" "${dst}/opt")
sdbs_exclude=("--exclude=/dev/* --exclude=/home/* --exclude=/proc/* --exclude=/run/* --exclude=/sys/* --exclude=/opt/* --exclude=/mnt/*" 
      "" 
      "" 
      "--exclude=/workspace/aosp_8.1.0_r33/ --exclude=/legacy/ --exclude=/media/Download/")

_backup() {
  local i=0
  for i in "${!sdbs[@]}"; do
    local size="`blockdev --getsize64 /dev/${sdbs[${i}]}`"
    # check size
    if [ "${size}" == "${sdbs_size[${i}]}" ]; then
      mkdir -p "${sdbs_dst[${i}]}"
      set +e
      echo "umount ${sdbs_dst[${i}]}"
      umount "${sdbs_dst[${i}]}" > /dev/null 2> /dev/null 
      set -e
      mount "/dev/${sdbs[${i}]}" "${sdbs_dst[${i}]}"
    else
      echo "something wrong! /dev/${sdbs[${i}]} size "${size}" are not "${sdbs_size[${i}]}"";
      exit 1
    fi

    local log="${sdbs_dst[${i}]}/rsync_${sdbs[${i}]}.log"
    echo "rsync -aruv --delete ${sdbs_src[${i}]} ${sdbs_dst[${i}]}/ ${sdbs_exclude[${i}]} > ${log} 2>> ${log}"
    time rsync -aruv  --delete ${sdbs_src[${i}]} ${sdbs_dst[${i}]}/ ${sdbs_exclude[${i}]} > ${log} 2>> ${log}
    echo `date` > ${sdbs_dst[${i}]}/LAST_UPDATE
  done
}

_umount() {
  local i=0
  for i in "${!sdbs[@]}"; do
    echo ${i} umount ${sdbs_dst[${i}]}
    set +e
    umount ${sdbs_dst[${i}]} > /dev/null 2> /dev/null
    set -e
  done
}

$@

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

export GOSH_PATH=/opt/gosh
source ${GOSH_PATH}/go_common.sh
export GOSH_FILE_PATH=$GOSH_PATH/go.sh

_go_rdp() {
  xfreerdp --plugin cliprdr -g 1920x1080 -u ${GO_RDP_USERNAME} -p ${GO_RDP_PASSWORD} ${GO_RDP_ADDRESS} &
}

_go_x11vnc() {
  local NAME=${GO_X11VNC_USERNAME}
  if [ -z "${NAME}" ];then
    NAME=${1}
  fi
  sudo /sbin/runuser ${NAME} -s /bin/bash -c "/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /home/${NAME}/.vnc/passwd -rfbport 5900 -shared &"
}

_go_chk_bad_blocks() {
  sudo badblocks -b 4096 -v /dev/sda > /tmp/bad-blocks.txt
}

_go_hdpardm_set_spin_down_time() {
  #sudo hdparm -S 250 /dev/sda > /tmp/spindown_time
  #sudo hdparm -B 255 /dev/sda > /tmp/spindown_time
  _log "this not work ironwof >= 8TB machine"
}

_go_disable_ironwolf_load_cycle_count_increasing() {
  # this only let idle_c to zero
  #sudo $GOSH_PATH/SeaChest_PowerControl_191_1183_64  --changePower --defaultMode --powerMode idle_b -d /dev/sda

  if [ -z "${GOSH_PATH}" ];then
    GOSH_PATH=${1}
  fi

  # this can let idle_c to zero, standby also to zero
  sudo $GOSH_PATH/SeaChest_PowerControl_191_1183_64 -d /dev/sda --EPCfeature disable
  sudo $GOSH_PATH/SeaChest_PowerControl_191_1183_64 -d /dev/sda --EPCfeature enable
  sudo $GOSH_PATH/SeaChest_PowerControl_191_1183_64 -d /dev/sda --EPCfeature disable
}

_go_show_ironwolf_setting() {
  sudo $GOSH_PATH/SeaChest_PowerControl_191_1183_64 --showEPCSettings -d /dev/sda
}

_go_get_load_cycle_count() {
  sudo smartctl -a /dev/sda | grep 193
}

_go_info() {
  top -n 1 > /tmp/top

  # Temp
  B=$(( `cat ${GO_CPU_TEMP_PATH}` / 1000 ))
  B=${B}C

  # CPU Freq
  C=$(( `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq` / 1000 ))
  C1=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

  # free
  H=$(( `free | grep Mem | tr -s ' ' | cut -d' ' -f4` / 1000 ))
  H=${H}M

  echo -n "Temp:${B}   CPU:${C}M(${C1})    Free:${H} "
}

_go_info_infinite() {
  while true; do _go_info ; echo ' '; sleep 1 ; done
}

_go_conf_home_backup() {
  source ~/.gosh/.go_pre.sh _alias
  USER=`whoami`
  GO_CONF_HOME_TARGET_DIR=${GO_CONF_DIR}/home/`whoami`

  if [ ! -d "${GO_CONF_HOME_TARGET_DIR}" ];then
    sudo mkdir -p ${GO_CONF_HOME_TARGET_DIR}
    sudo chown ${USER}.${USER}
  fi

  for i in "${!GO_CONF_HOME_BACKUP_LIST[@]}"; do
    sudo rsync -aryuv ~/${GO_CONF_HOME_BACKUP_LIST[i]} ${GO_CONF_HOME_TARGET_DIR}
  done
}

_go_conf_etc_backup() {
  sudo rsync -aryuv /etc/ ${GO_CONF_DIR}/etc/
}

_go_iptables_clear() {
  sudo ${GO_IPTABLES_SH_PATH}/0go_iptables _clear
  sudo ${GO_IPTABLES_SH_PATH}/0go_ip6tables _clear
}

_go_iptables_list() {
  echo "##################### iptables ##################"
  sudo iptables -L

  echo ""
  echo "##################### iptables6 ##################"
  sudo ip6tables -L
}

_go_iptables_apply() {
  sudo ${GO_IPTABLES_SH_PATH}/0go_iptables _apply
  sudo ${GO_IPTABLES_SH_PATH}/0go_ip6tables _apply
}

_alias() {
  if [ -f ~/.gosh/.go_pre.sh ]; then
    source ~/.gosh/.go_pre.sh _alias
  fi

  alias gosh="cd ${GOSH_PATH}"
  alias go_rdp="$GOSH_FILE_PATH _go_rdp"
  alias go_x11vnc="$GOSH_FILE_PATH _go_x11vnc"
  alias go_chk_bad_blocks="$GOSH_FILE_PATH _go_chk_bad_blocks"
  alias go_hdpardm_set_spin_down_time="$GOSH_FILE_PATH _go_hdpardm_set_spin_down_time"
  alias go_get_load_cycle_count="$GOSH_FILE_PATH _go_get_load_cycle_count"
  alias go_disable_ironwolf_load_cycle_count_increasing="$GOSH_FILE_PATH _go_disable_ironwolf_load_cycle_count_increasing"
  alias go_show_ironwolf_setting="$GOSH_FILE_PATH _go_show_ironwolf_setting"
  alias go_cpufreq="cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq"
  alias go_temp="cat /sys/class/thermal/thermal_zone*/temp"
  alias go_trafshow="sudo trafshow -R 1 -i ${GO_ETH0_NAME}"
  alias go_trafshow_udp="sudo trafshow -R 1 -i ${GO_ETH0_NAME} udp"
  alias go_info="$GOSH_FILE_PATH _go_info_infinite"
  alias go_conf_home_backup="$GOSH_FILE_PATH _go_conf_home_backup"
  alias go_conf_etc_backup="$GOSH_FILE_PATH _go_conf_etc_backup"
  alias go_iptables_clear="$GOSH_FILE_PATH _go_iptables_clear"
  alias go_iptables_list="$GOSH_FILE_PATH _go_iptables_list"
  alias go_iptables_apply="$GOSH_FILE_PATH _go_iptables_apply"

  source $GOSH_PATH/go_githelper.sh _alias
  source $GOSH_PATH/go_bootstrap.sh _alias
  source $GOSH_PATH/go_ffmpeg.sh _alias
  source $GOSH_PATH/go_qos.sh _alias
  source $GOSH_PATH/go_strongswan.sh _alias
  source $GOSH_PATH/go_cert.sh _alias

  if [ -f ~/.gosh/.go_post.sh ]; then
    source ~/.gosh/.go_post.sh _alias
  fi
}

$@


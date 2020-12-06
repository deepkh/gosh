## My local linux box script collection and aliased 'go_' function
---

Clone this repo to `/opt`

```bash
cd /opt
git clone https://github.com/deepkh/gosh.git
```

Add the line to bottom of `/home/user/.bashrc` and `/root/.bashrc`

```bash
source /opt/gosh/go.sh _alias
```

Copy and fill the variables to your `/home/user/.go_pre.sh` and `sudo ln -sf /home/user/.go_pre.sh /root/.go_pre.sh`

```bash
#!/bin/bash

############ for go.sh 
export WHOAMI="yourname"
export GO_CONF_DIR="/opt/goconf"
export GO_CONF_HOME_BACKUP_LIST=".ssh .vim .vnc .bashrc .gitconfig .git-credentials .go_pre.sh .go_post.sh .gvimrc .vimrc "

export GO_RDP_USERNAME="${WHOAMI}"
export GO_RDP_PASSWORD="YOUR_PASSWORD"
export GO_RDP_ADDRESS="IP:3389"
export GO_X11VNC_USERNAME="${WHOAMI}"
export GO_ETH0_NAME="enp4s0"
export GO_ETH1_NAME="enp0s31f6"
export GO_NFS_MNT_OPTS=""
export GO_NFS_SERVER_ADDR=""
export GO_CPU_TEMP_PATH="/sys/class/thermal/thermal_zone2/temp"
export CSCOPE_EDITOR=vim

############ for go_bootstrap.sh
export BOOTSTRAP_DEFAULT_USER="${WHOAMI}"
export BOOTSTRAP_DEFAULT_PASSWD=YOUR_PASSWORD

```

Everytime you login into the `user` account  and  then the `go` alias function will automatically display after press `go <TAB><TAB>` on terminal.

```bash
dogi@ubtser:/opt/gosh$ go
go_1_netsync                                     go_qos_10mbps
go_1_netsync_mingw.linux                         go_qos_15mbps
go_backup                                        go_qos_20mbps
go_bootstrap.sh                                  go_qos_25mbps
go_chk_bad_blocks                                go_qos_2mbps
go_cloudflare_dns_updater.sh                     go_qos_30mbps
go_conf_etc_backup                               go_qos_40mbps
go_conf_home_backup                              go_qos_50mbps
go_cpufreq                                       go_qos_5mbps
go_disable_ironwolf_load_cycle_count_increasing  go_qos_60mbps
go_drmdump_aarch64                               go_qos_70mbps
go_drmdump_linux                                 go_qos_80mbps
go_ff_enc_with_srt                               go_qos_init
go_ff_extract_srt                                go_qos.sh
go_ff_extract_srts                               go_rdp
go_ffmpeg.sh                                     go_rootfs
go_ff_rtmp_push_fb                               go.sh
go_ff_show_srts                                  gosh/
go_ff_two_pass_enc                               go_show_ironwolf_setting
go_ff_two_pass_enc_with_srt                      go_srt
go_get_load_cycle_count                          go_temp
go_githelper.sh                                  go_test_video
go_hdpardm_set_spin_down_time                    go_trafshow
go_info                                          go_trafshow_udp
go_ip6tables.sh                                  go_ttg_upload
go_iptables.sh                                   go_umnt_media
go_media                                         go_umnt_workspace
go_mnt_media                                     go_workspace
go_mnt_workspace                                 go_x11vnc
go_mosquitto_broker
```

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

export GO_QOS_FILE_PATH=${GOSH_PATH}/go_qos.sh


iptables="sudo /sbin/iptables"
modprobe="sudo /sbin/modprobe"
tc="sudo /usr/sbin/tc"
ETH0=$GO_ETH0_NAME
ETH1=$GO_ETH1_NAME
CLIENT_A=192.168.5.3/24

HTB_OUTGOING_BW="10000kbps"            #80Mbps
HTB_INCOMING_BW="5000kbps"             #40Mbps

HTB_2MBPS="250kbps"
HTB_5MBPS="625kbps"
HTB_10MBPS="1250kbps"
HTB_15MBPS="1875kbps"
HTB_20MBPS="2500kbps"
HTB_25MBPS="3125kbps"
HTB_30MBPS="3750kbps"
HTB_40MBPS="5000kbps"
HTB_50MBPS="6250kbps"
HTB_60MBPS="7500kbps"
HTB_70MBPS="8750kbps"
HTB_80MBPS="10000kbps"

_clear() {
  $iptables -F
  $iptables -X
  $iptables -Z
  $iptables -P INPUT ACCEPT
  $iptables -P OUTPUT ACCEPT
  $iptables -P FORWARD ACCEPT
  $iptables -t nat -F
  $iptables -t nat -X
  $iptables -t nat -Z
  $iptables -t nat -P PREROUTING ACCEPT
  $iptables -t nat -P POSTROUTING ACCEPT
  $iptables -t nat -P OUTPUT ACCEPT
}

_nat() {
  echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
  $iptables -t nat -A POSTROUTING -o $ETH0 -s $CLIENT_A -j MASQUERADE
  $iptables -A FORWARD -i $ETH1 -o $ETH0 -s $CLIENT_A -j ACCEPT
  $iptables -A FORWARD -i $ETH0 -o $ETH1 -d $CLIENT_A -j ACCEPT
}

_htb_outgoing_parent() {
  $tc qdisc del dev $ETH1 root 2> /dev/null
  $tc qdisc add dev $ETH1 root handle 10: htb default 20
  $tc class add dev $ETH1 parent 10: classid 10:1 htb rate $1 ceil $1    #Guarantee 20Mbps ; Maximum 20Mbps
}

_htb_outgoing_limit() {
  $tc class add dev $ETH1 parent 10:1 classid 10:$2 htb rate $1 ceil $1 prio 0                   
  $tc qdisc add dev $ETH1 parent 10:$2 handle $3: pfifo
  $tc filter add dev $ETH1 parent 10: protocol ip prio 100 handle $2 fw classid 10:$2
}

_qos_init() {
  _clear
  _nat
  _htb_outgoing_parent $HTB_OUTGOING_BW
  _htb_outgoing_limit $HTB_2MBPS 2 101
  _htb_outgoing_limit $HTB_5MBPS 5 102
  _htb_outgoing_limit $HTB_10MBPS 10 103
  _htb_outgoing_limit $HTB_15MBPS 15 104
  _htb_outgoing_limit $HTB_20MBPS 20 105
  _htb_outgoing_limit $HTB_25MBPS 25 106
  _htb_outgoing_limit $HTB_30MBPS 30 107
  _htb_outgoing_limit $HTB_40MBPS 40 108
  _htb_outgoing_limit $HTB_50MBPS 50 109
  _htb_outgoing_limit $HTB_60MBPS 60 110
  _htb_outgoing_limit $HTB_70MBPS 70 111
  _htb_outgoing_limit $HTB_80MBPS 80 112
}

_qos_mark() {
  $iptables -F -t mangle
  $iptables -t mangle -A POSTROUTING -d $CLIENT_A -j MARK --set-mark $1
}

_alias() {
  alias go_qos_init="$GO_QOS_FILE_PATH _qos_init"
  alias go_qos_2mbps="$GO_QOS_FILE_PATH _qos_mark 2"
  alias go_qos_5mbps="$GO_QOS_FILE_PATH _qos_mark 5"
  alias go_qos_10mbps="$GO_QOS_FILE_PATH _qos_mark 10"
  alias go_qos_15mbps="$GO_QOS_FILE_PATH _qos_mark 15"
  alias go_qos_20mbps="$GO_QOS_FILE_PATH _qos_mark 20"
  alias go_qos_25mbps="$GO_QOS_FILE_PATH _qos_mark 25"
  alias go_qos_30mbps="$GO_QOS_FILE_PATH _qos_mark 30"
  alias go_qos_40mbps="$GO_QOS_FILE_PATH _qos_mark 40"
  alias go_qos_50mbps="$GO_QOS_FILE_PATH _qos_mark 50"
  alias go_qos_60mbps="$GO_QOS_FILE_PATH _qos_mark 60"
  alias go_qos_70mbps="$GO_QOS_FILE_PATH _qos_mark 70"
  alias go_qos_80mbps="$GO_QOS_FILE_PATH _qos_mark 80"
}

$@

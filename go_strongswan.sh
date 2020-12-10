#!/bin/bash

#set -e

export GO_STRONGSWAN_FILE_PATH=${GOSH_PATH}/go_strongswan.sh

_strongswan_packages_install() {
  sudo apt-get install strongswan strongswan-swanctl strongswan-pki iptables-persistent libstrongswan-extra-plugins libstrongswan-standard-plugins libcharon-extra-plugins resolvconf --no-install-recommends
}

# Install StrongSwan Server's X509 Certificate to /etc/ipsec.d/private/ and /etc/ipsec.d/certs/ 
_strongswan_ca_install() {
  local CA_KEY="${1}"
  local CA_CRT="${2}"
  sudo cp ${CA_KEY} /etc/ipsec.d/private
  sudo cp ${CA_CRT} /etc/ipsec.d/certs
}

# Setting /etc/ipsec.secrets
_strongswan_ipsec_secrets_gen() {
  local CA_CN="${1}"
  local CA_KEY="${2}"
  local CA_PASSWORD="${3}"
  local EAP_USERNAME="${4}"
  local EAP_PASSWORD="${5}"

  sudo bash -c "cat > /etc/ipsec.secrets << EOF1
${CA_CN} : RSA \"${CA_KEY}\"  \"${CA_PASSWORD}\"
${EAP_USERNAME} : EAP \"${EAP_PASSWORD}\"
EOF1"
}

# Setting /etc/ipsec.secrets
_strongswan_ipsec_secrets_gen_without_password() {
  local CA_CN="${1}"
  local CA_KEY="${2}"
  local CA_PASSWORD="${3}"
  local EAP_USERNAME="${4}"
  local EAP_PASSWORD="${5}"

  sudo bash -c "cat > /etc/ipsec.secrets << EOF1
${CA_CN} : RSA \"${CA_KEY}\"
${EAP_USERNAME} : EAP \"${EAP_PASSWORD}\"
EOF1"
}

# Setting /etc/ipsec.conf
_strongswan_ipsec_conf() {
  local SERVER_CN="${1}"
  local SERVER_CRT="${2}"

  sudo bash -c "cat > /etc/ipsec.conf << EOF2
config setup
    charondebug=\"ike 2, knl 0, cfg 0\"
    uniqueids=no

conn ikev2-vpn
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    fragmentation=yes
    forceencaps=yes
    ike=aes256-sha1-modp1024,aes128-sha1-modp1024,3des-sha1-modp1024! # Win7 is aes256, sha-1, modp1024; iOS is aes256, sha-256, modp1024; OS X is 3DES, sha-1, modp1024
    esp=aes256-sha256,aes256-sha1,3des-sha1!                          # Win 7 is aes256-sha1, iOS is aes256-sha256, OS X is 3des-shal1
    dpdaction=clear
    dpddelay=3000s
    rekey=no
    #Server
    left=%any
    leftid=@${SERVER_CN}
    leftcert=${SERVER_CRT}
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    #Client
    right=%any
    rightid=%any
    rightdns=8.8.8.8,8.8.4.4
    rightsourceip=10.10.10.0/24
    #rightcert=VPNCA3.crt       can't working, instead of following 3 items
    rightauth=eap-mschapv2
    rightsendcert=never
    eap_identity=%identity
EOF2"
}

_strongswan_strongswan_conf() {
  sudo bash -c "cat > /etc/strongswan.conf << EOF3
charon {
    #duplicheck.enable = no
    load = eap-mschapv2 
    install_virtual_ip = yes
    dns1 = 8.8.8.8
    dns2 = 8.8.4.4
    load_modular = yes
    plugins {
        include strongswan.d/charon/*.conf
    }
}

include strongswan.d/*.conf
EOF3"
}

_strongswan_restart() {
  set +e
  sudo systemctl enable strongswan-starter
  sudo systemctl restart strongswan-starter
  sudo ipsec restart
  sleep 1
  _strongswan_status
}

_strongswan_status() {
  sudo ipsec statusall
}

_strongswan_log() {
  sudo cat /var/log/syslog
}

_alias() {
  alias strongswan_packages_install="$GO_STRONGSWAN_FILE_PATH _strongswan_packages_install"
  alias strongswan_restart="$GO_STRONGSWAN_FILE_PATH _strongswan_restart"
  alias strongswan_status="$GO_STRONGSWAN_FILE_PATH _strongswan_status"
  alias strongswan_log="$GO_STRONGSWAN_FILE_PATH _strongswan_log"
  
  alias strongswan_strongswan_conf="$GO_POST_FILE_PATH _strongswan_strongswan_conf"
}

$@


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
export GO_CERT_FILE_PATH=${GOSH_PATH}/go_cert.sh

# Generate RootCA's X509 Certificate
_go_cert_rootca_gen() {
  local PREFIX="$1"
  local PASSWORD="$2"
  local CN="$3"
  local CA_PATH="$4"
  openssl genrsa -aes256 -out "${CA_PATH}/${PREFIX}.key" -passout pass:"${PASSWORD}" 2048
  openssl req -new -sha256 -key "${CA_PATH}/${PREFIX}.key" -subj "/O=${CN}/CN=${CN}" -config <(cat ${GOSH_PATH}/cert/openssl.cnf ) -out "${CA_PATH}/${PREFIX}.csr" -extensions v3_ca -passin pass:"${PASSWORD}"
  openssl x509 -req -in "${CA_PATH}/${PREFIX}.csr" -sha256 -out "${CA_PATH}/${PREFIX}.crt" -days 10950 -signkey "${CA_PATH}/${PREFIX}.key" -extfile ${GOSH_PATH}/cert/openssl.cnf -extensions v3_ca -passin pass:"${PASSWORD}"
}

# Generate StrongSwan Server's X509 Certificate
_go_cert_serverca_gen() {
  local PREFIX="$1"
  local PASSWORD="$2"
  local CN="$3"
  local CA_PATH="$4"
  local SAN="$5"
  local ROOTCA_CN="$6"
  local ROOTCA_PREFIX="$7"
  local ROOTCA_PASSWORD="$8"
 
  openssl genrsa -aes256 -out "${CA_PATH}/${PREFIX}.key" -passout pass:"${PASSWORD}" 2048
  openssl req -new -sha256 -key "${CA_PATH}/${PREFIX}.key" -subj "/O=${ROOTCA_CN}/CN=${CN}" -config <(cat ${GOSH_PATH}/cert/openssl.cnf ) -out "${CA_PATH}/${PREFIX}.csr" -extensions v3_ca -passin pass:"${PASSWORD}"
  openssl x509 -req -in "${CA_PATH}/${PREFIX}.csr" -CA "${CA_PATH}/${ROOTCA_PREFIX}.crt" -CAkey "${CA_PATH}/${ROOTCA_PREFIX}.key" -CAcreateserial -sha256 -out "${CA_PATH}/${PREFIX}.crt" -days 3650 -extfile <(cat ${GOSH_PATH}/cert/openssl.cnf <(printf "subjectAltName=${SAN}")) -extensions server_cert2 -passin pass:"${ROOTCA_PASSWORD}"
}

# Generate StrongSwan Server's X509 Certificate
_go_cert_serverca_gen_without_password() {
  local PREFIX="$1"
  local PASSWORD="$2"
  local CN="$3"
  local CA_PATH="$4"
  local SAN="$5"
  local ROOTCA_CN="$6"
  local ROOTCA_PREFIX="$7"
  local ROOTCA_PASSWORD="$8"
 
  openssl genrsa -aes256 -out "${CA_PATH}/${PREFIX}-encrypted.key" -passout pass:"${PASSWORD}" 2048
  openssl rsa -in "${CA_PATH}/${PREFIX}-encrypted.key" -out "${CA_PATH}/${PREFIX}.key" -passin pass:"${PASSWORD}"
  openssl req -new -sha256 -key "${CA_PATH}/${PREFIX}.key" -subj "/O=${ROOTCA_CN}/CN=${CN}" -config <(cat ${GOSH_PATH}/cert/openssl.cnf ) -out "${CA_PATH}/${PREFIX}.csr" -extensions server_cert2
  openssl x509 -req -in "${CA_PATH}/${PREFIX}.csr" -CA "${CA_PATH}/${ROOTCA_PREFIX}.crt" -CAkey "${CA_PATH}/${ROOTCA_PREFIX}.key" -CAcreateserial -sha256 -out "${CA_PATH}/${PREFIX}.crt" -days 3650 -extfile <(cat ${GOSH_PATH}/cert/openssl.cnf <(printf "subjectAltName=${SAN}")) -extensions server_cert2 -passin pass:"${ROOTCA_PASSWORD}"
}

# Generate StrongSwan Client's X509 Certificate
_clientca_gen() {
  openssl genrsa -aes256 -out $CLIENT_PREFIX.key 2048
  openssl req -new -sha256 -key $CLIENT_PREFIX.key -subj "/CN=$CLIENT_CN" -config <(cat openssl.cnf ) -out $CLIENT_PREFIX.csr -extensions server_cert2 
  openssl x509 -req -in $CLIENT_PREFIX.csr -CA $ROOTCA_PREFIX.crt -CAkey $ROOTCA_PREFIX.key -CAcreateserial -sha256 -out $CLIENT_PREFIX.crt -days 3650 -extfile <(cat openssl.cnf <(printf "subjectAltName=DNS:$CLIENT_CN")) -extensions server_cert2 -passin pass:$ROOTCA_PASSWORD

  #generate PKCS#12(.p12) 
  openssl pkcs12 -export -out $CLIENT_PREFIX.p12 -inkey $CLIENT_PREFIX.key -in $CLIENT_PREFIX.crt -certfile $ROOTCA_PREFIX.crt
}

_alias() {
  alias go_cert_rootca_gen="$GO_CERT_FILE_PATH _go_cert_rootca_gen"
  alias go_cert_serverca_gen="$GO_CERT_FILE_PATH _go_cert_serverca_gen"
}

$@


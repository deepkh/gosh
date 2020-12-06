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

_log() {
  if [ -z "${LOG_FILE}" ];then
    LOG_FILE=/dev/null
  fi
  MSG="[`LC_ALL=C date`] $1"
  echo -e "${MSG}" >> ${LOG_FILE}
  echo -e "${MSG}" 
}

_do_func() {
  echo ""
  echo "####### $1 #######"
  func=$2
  shift				#shift $1
  shift				#shift $2
  ($func "$@")
}


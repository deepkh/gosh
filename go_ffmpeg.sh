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

export GO_FF_FILE_PATH=${GOSH_PATH}/go_ffmpeg.sh

_extract_srt() {
  strlen=${#1}
  srtname=${1:0:$strlen-4}.srt
  ffmpeg -i "$1" -map 0:$2 "$srtname"
}

_extract_srts() {
  for file in "$1"/*
  do
    if [[ -f "$file" ]]; then
      echo "$file"
      _extract_srt "$file" $2
    fi
  done

}

_show_srts() {
  ffprobe -loglevel error -select_streams s -show_entries stream=index:stream_tags=language -of csv=p=0 $@
}

_two_pass_enc_with_srt() {
  strlen=${#1}
  filename=${1:0:$strlen-4}
  bitrate="1000k"
  rm -f ffmpeg2pass-0.log ffmpeg2pass-0.log.mbtree $filename.mp4
  ffmpeg -y -i $1 -c:v libx264 -b:v $bitrate -pass 1 -an -f mp4 /dev/null && \
  ffmpeg -i  $1 -vf "[in] scale=1280:720, subtitles=$filename.srt:force_style='Fontsize=24'" -c:v libx264 -b:v $bitrate -pass 2 -c:a aac -b:a 128k $filename.mp4
}

_enc_with_srt() {
  strlen=${#1}
  filename=${1:0:$strlen-4}
  bitrate="1000k"
  rm -f ffmpeg2pass-0.log ffmpeg2pass-0.log.mbtree $filename.mp4
  ffmpeg -i  $1 -vf "[in] scale=1280:720, subtitles=$filename.srt:force_style='Fontsize=24'" -c:v libx264 -b:v $bitrate -c:a aac -b:a 128k $filename.mp4
}

_rtmp_push_to_fb() {
  ffmpeg -c:v h264 -i $1 -f alsa -i hw:0,0 -ar 48000 -c:v copy -c:a aac -b:a 128k  -f flv -y "rtmps://live-api-s.facebook.com:443/rtmp/2369171593095174?s_bl=1&s_ps=1&s_sw=0&s_vt=api-s&a=AbxEB3kakGyfNW2f"
  
}

_alias() {
  alias go_ff_show_srts="$GO_FFSH_FILE_PATH _show_srts"
  alias go_ff_extract_srt="$GO_FFSH_FILE_PATH _extract_srt"
  alias go_ff_extract_srts="$GO_FFSH_FILE_PATH _extract_srts"
  alias go_ff_two_pass_enc="$GO_FFSH_FILE_PATH _two_pass_enc"
  alias go_ff_two_pass_enc_with_srt="$GO_FFSH_FILE_PATH _two_pass_enc_with_srt"
  alias go_ff_enc_with_srt="$GO_FFSH_FILE_PATH _enc_with_srt"
  alias go_ff_rtmp_push_fb="$GO_FFSH_FILE_PATH _rtmp_push_to_fb"
}

$@

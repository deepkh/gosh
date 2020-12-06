#!/bin/bash

set -e

source ~/aosp_bin/aosp_helper.sh _aosp_source

for var in "$@"
do
  echo "============================================================================="
  echo "                              mmm $var"
  echo "============================================================================="
  mmm "$var" -j8
done

aosp

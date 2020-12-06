#!/bin/bash

_make_is_target_dir() {
  local _ary=($@)
  local _dir=${_ary[0]}
  local _pwd=${_ary[1]}
  local _match_files=("${_ary[@]:2}")

  for matched in "${_match_files[@]}"
  do
    if [ "${_dir}" = "${_pwd}/${matched}_intermediates" ];then
      # 0 = true
      return 0
    elif [ "${_dir}" = "${_pwd}/${matched}" ]; then
      # 0 = true
      return 0
    fi
  done

  # 1 = false
  return 1
}

_make_is_target_file() {
  local _ary=($@)
  local _file=${_ary[0]}
  local _pwd=${_ary[1]}
  local _match_files=("${_ary[@]:2}")

  for matched in "${_match_files[@]}"
  do
    if [ "${_file}" = "${_pwd}/${matched}.so" ];then        #SHARED
      # 0 = true
      return 0
    elif [ "${_file}" = "${_pwd}/${matched}.a" ]; then        #STATIC
      # 0 = true
      return 0
    elif [ "${_file}" = "${_pwd}/${matched}" ]; then        #EXECUTE
      # 0 = true
      return 0
    fi
  done

  # 1 = false
  return 1
}


_make_traverse_condition() {
  local _ary=($@)
  local _f=${_ary[0]}
    local _pwd=${_ary[1]}
    local _index_dir=${_ary[2]}
    local _index_file=${_ary[3]}
    local _match_files=("${_ary[@]:4}")     #slice to the end of the array

  if [ "${f}" = "${_pwd}/." ]; then
    return
  elif [ "${f}" = "${_pwd}/.." ]; then
    return
  elif [ "${f}" = "${_pwd}/.glob" ]; then
    return
  else
    #index dir
    if  [ -d "${f}" ] ; then
      if _make_is_target_dir "${f}" "${_pwd}" "${_match_files[@]}" && [ "${_index_dir}" = "1" ]; then
        echo "${f}"; 
      else 
        _make_index "${f}" "${_index_dir}" "${_index_file}" "${_match_files[@]}" 
      fi
    fi

    #index file
    if [[ -f "${f}" && "${_index_file}" = "1" ]]; then
      if _make_is_target_file "${f}" "${_pwd}" "${_match_files[@]}"; then 
        echo "${f}"; 
      fi
    fi
  fi
}

_make_index() {
  local _ary=($@)
    local _pwd=${_ary[0]}
    local _index_dir=${_ary[1]}
    local _index_file=${_ary[2]}
    local _match_files=("${_ary[@]:3}")     #slice to the end of the array

  #echo ENTER ${_pwd}

  # traverse non-hidden dir
  for f in "${_pwd}"/.*
  do
    #_make_traverse_condition "${1}" "${2}" "${f}"
    _make_traverse_condition ${f} ${_ary[@]}
  done
  
  # traverse hidden dir
  for f in "${_pwd}"/*
  do
    #_make_traverse_condition "${1}" "${2}" "${f}"
    _make_traverse_condition ${f} ${_ary[@]}
  done
}

_make_mmm() {
  USE_CCACHE=1
  source ~/bin/aosp_helper.sh _aosp_source
  set -e

  for i in "$@"
  do
    echo "=================================================================="
    echo "                   building ${i}"
    echo "=================================================================="
    mmm "${i}" -j8
  done
}

_make_install() {
  local _ary=($@)
  local _src=${_ary[0]}
  local _dst=${_ary[1]}
  local _files=("${_ary[@]:2}")     #slice to the end of the array
  
  for f in "${_files[@]}"
  do
    adb push ${_src}/${f} ${_dst}/${f}
  done
}

$@

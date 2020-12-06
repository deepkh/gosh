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

GIT_HELPER_FILE_PATH=${GOSH_PATH}/go_githelper.sh

_git_submodules_checkout() {
  local master="master"

  if [ "$1" != "" ];then
    master="$1"
  fi

  echo $master

  git submodule foreach --recursive git checkout -b ${master}
}

_git_submodules_update() {
  git submodule update --init --recursive
}

_git_pull_all() {
  git pull origin master
  git submodule foreach --recursive git pull origin master
}

_git_pull() {
  local origin="origin"
  local master="master"

  if [ "$1" != "" ];then
    origin="$1"
  fi

  if [ "$2" != "" ];then
    master="$2"
  fi

  git pull $origin $master
}

_git_status_all() {
  git submodule foreach --recursive git status 
  git status 
}

_git_log_submodules() {
  local logs=`git submodule foreach --recursive git log --oneline --decorate -5`
  #local logs=`git log --oneline --decorate -1`
  local count=0
  local project=""

  echo -e "\e[1;34mCurrent\e[0m"

  # show current project log
  git log --oneline --decorate -5

  # show submodule log
  IFS=$'\n' b_array=(${logs})
  for i in "${b_array[@]}"
  do
    local prj=`echo $i | grep "Entering"`
    if [ ! -z "$prj" ]; then
      prj=`echo ${i} | cut -d' ' -f2`
      prj=${prj//"'"/""}
      echo -e "\e[1;34m$prj\e[0m"
    else
      local hash=`echo ${i} | cut -d' ' -f1`
      local log=`echo ${i} | grep -o " .*"`
      echo -e "\e[0;33m$hash\e[0m"${log}
    fi
  done
}

_git_log() {
  # it's submodule mode
  if [ -z "$1" ];then
    _git_log_submodules
    exit
  fi

  # it's show by specified args
  for dir in "$@"
  do
    cd "${dir}"
    echo -e "\e[1;34m${dir}\e[0m"

    # show current project log
    git log --oneline --decorate -5
  done
}

_git_log_all() {
  # it's submodule mode
  if [ -z "$1" ];then
    git log --oneline --decorate --all --graph
    exit
  fi

  # it's show by specified args
  for dir in "$@"
  do
    cd "${dir}"
    echo -e "\e[1;34m${dir}\e[0m"

    # show current project log
    git log --oneline --decorate --all --graph 
  done
}

_git_log_decoration() {
  # it's submodule mode
  if [ -z "$1" ];then
    git log --oneline --decorate --all --graph --simplify-by-decoration
    exit
  fi

  # it's show by specified args
  for dir in "$@"
  do
    cd "${dir}"
    echo -e "\e[1;34m${dir}\e[0m"

    # show current project log
    git log --oneline --decorate --all --graph --simplify-by-decoration
  done
}

_git_log_stat() {
  # it's submodule mode
  if [ -z "$1" ];then
    git log --oneline --decorate --all --graph --stat
    exit
  fi

  # it's show by specified args
  for dir in "$@"
  do
    cd "${dir}"
    echo -e "\e[1;34m${dir}\e[0m"

    # show current project log
    git log --oneline --decorate --all --graph --stat
  done
}

_git_commit_push() {
  local origin="origin"
  #local master="master"
  local master="`git branch | grep \* | cut -d ' ' -f2`"

  if [ "$1" != "" ];then
    origin="$1"
  fi

  if [ "$2" != "" ];then
    master="$2"
  fi

  git commit -a
  git push $origin $master
}

_git_status_log() {
  local path="$1"
  local prj="$2"
  local is_root=0

  # ls-tree
  local ls_tree_commit_id="`git ls-tree @ "${prj}" | cut -d' ' -f3 `"
  ls_tree_commit_id=${ls_tree_commit_id:0:7}

  # is_root
  if [ "${path}" = "." ];then
    is_root=1
  fi

  # log --oneline --decorate
  if [ $is_root -eq 0 ];then
    cd ${prj}
  fi
  local head_commit_log="`git log --oneline --decorate -1`"
  local head_commit_id=${head_commit_log:0:7}

  # branch
  local branch="`git branch | grep '* ' | cut -d' ' -f2`"
  branch=${branch//"("/""}
  
  if [ $is_root -eq 1 ]; then
    # show root
    printf "\e[1;34m%-30s\e[0m \e[1;32m%-10s\e[0m _______ %s\n" "${path}" "${branch}" "${head_commit_log}"
  else
    # show submodule
    # give red color if ls-tree commit_id not equal head_commit_id
    if [ "${ls_tree_commit_id}" != "${head_commit_id}" ];then
      log="[1;5;34m${ls_tree_commit_id}\e[0m | ${head_commit_log}"
      printf "\e[1;34m%-30s\e[0m \e[1;32m%-10s\e[0m \e[1;31m%s\e[0m \e[1;31m%s\e[0m\n" "${path}" "${branch}" "${ls_tree_commit_id}" "${head_commit_log}"
    else
      printf "\e[1;34m%-30s\e[0m \e[1;32m%-10s\e[0m %s %s\n" "${path}" "${branch}" "${ls_tree_commit_id}" "${head_commit_log}"
    fi
  fi

  # status of renamed, new file, deleted, modified
  local status_log="`git status -uno | grep -e 'renamed:' -e 'new file:' -e 'deleted:' -e 'modified:'`"

  # do align
  if [ ! -z "${status_log}" ];then
    IFS=$'\n' b_array=(${status_log})
    for line in "${b_array[@]}"
    do
      line=${line//"  "/""}
      printf "%-30s %-10s \e[1;35m%s\e[0m\n" "" "" "${line}"
    done
  fi
  
  #if [ "${path}" != "." ];then
  if [ $is_root -eq 0 ];then
    cd ..
  fi
}

_git_status() {
  local path=$1
  local submodules=
  
  if [ -z "$path" ];then
    # print title
    printf "\e[1;33m%-30s\e[0m \e[1;33m%-10s\e[0m \e[1;33m%-7s\e[0m \e[1;33m%s\e[0m\n" "repo" "branch" "ls-tree" "commit"

    path="."
    _git_status_log "." "."
  fi

  # extract .gitmodules
  if [ -f ".gitmodules" ];then
    submodules="`cat .gitmodules`"
    IFS=$'\n' b_array=(${submodules})
    for i in "${b_array[@]}"
    do
      prj=`echo $i | grep "path = "`
      if [ ! -z "$prj" ]; then
        prj=${i//" "/""}
        prj=${prj//"  "/""}
        prj=`echo ${prj} | cut -d'=' -f2`

        # show ls-tree and HEAD of this submodule
        _git_status_log "${path}/${prj}" "${prj}"

        # process recursive
        cd ${prj}
        _git_status "${path}/${prj}"
        cd ..
      fi

#     these seen have program on mingw
#     # parse .gitmodules
#     local prj=`echo $i | grep "submodule"`
#     if [ ! -z "$prj" ]; then
#       prj=`echo ${i} | cut -d' ' -f2`
#       prj=${prj//"["/""}
#       prj=${prj//"]"/""}
#       prj=${prj//"\""/""}

#       # show ls-tree and HEAD of this submodule
#       _git_ls_tree_log "${path}/${prj}" "${prj}"

#       # process recursive
#       cd ${prj}
#       _git_ls_tree "${path}/${prj}"
#       cd ..
#     fi
    done
  fi
}

_alias() {
  alias git_submodules_checkout="${GIT_HELPER_FILE_PATH} _git_submodules_checkout"
  alias git_submodules_update="${GIT_HELPER_FILE_PATH} _git_submodules_update"
  alias git_pull_all="${GIT_HELPER_FILE_PATH} _git_pull_all"
  alias git_pull="${GIT_HELPER_FILE_PATH} _git_pull"
  alias git_status_all="${GIT_HELPER_FILE_PATH} _git_status_all"
  alias git_log="${GIT_HELPER_FILE_PATH} _git_log"
  alias git_log_all="${GIT_HELPER_FILE_PATH} _git_log_all"
  alias git_log_decoration="${GIT_HELPER_FILE_PATH} _git_log_decoration"
  alias git_log_stat="${GIT_HELPER_FILE_PATH} _git_log_stat"
  alias git_status="${GIT_HELPER_FILE_PATH} _git_status"
  alias git_commit_push="${GIT_HELPER_FILE_PATH} _git_commit_push"
}
  
$@



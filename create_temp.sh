#!/bin/env bash

# Create temporary directory
# + -t flag is explicit to be complaint
# + with MacOS older versions
function create_temp () {
  local suff_str exec_cmd
  local usage="create_temp <SUFFIX>"
  if [[ $1 == -h ]]; then
    echo "$usage";
  fi
  suff_str=''
  exec_cmd="mktemp -d -t 'tmp.XXXXXXXXX'"
  if [[ ! "$1" == "" ]]; then
    suff_str=" --suffix "-$1""
    exec_cmd="${exec_cmd} ${suff_str}"
  fi
  eval "${exec_cmd}"
}

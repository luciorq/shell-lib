#!/usr/bin/env bash

# Create temporary directory
# + -t flag is explicit to be complaint
# + with MacOS older coreutils versions
function create_temp () {
  local suff_str exec_cmd mktemp_bin;
  local usage="create_temp <SUFFIX>";
  if [[ $1 == -h ]]; then
    builtin echo -ne "${usage}\n";
  fi
  suff_str='';
  mktemp_bin="$(which_bin 'mktemp')";
  exec_cmd="${mktemp_bin} -d -t 'tmp.XXXXXXXXX'";
  if [[ ! "$1" == "" ]]; then
    suff_str=" --suffix \"-$1\"";
    exec_cmd="${exec_cmd} ${suff_str}";
  fi
  builtin eval "${exec_cmd}";
}

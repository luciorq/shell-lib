#!/usr/bin/env bash

function clear_pure () {
  \builtin local printf_type;
  \builtin local echo_type;
  \builtin local clear_bin;
  printf_type="$(\builtin command type -ta printf)";
  echo_type="$(\builtin command type -ta echo)";
  clear_bin="$(which_bin 'clear')";

  if [[ ${echo_type} =~ builtin ]]; then
    \builtin echo -ne "\ec";
  elif [[ ${printf_type} =~ builtin ]]; then
    \builtin printf "\033c";
  elif [[ -n ${clear_bin} ]]; then
    \builtin eval "${clear_bin}";
  fi
  \builtin return 0;
}

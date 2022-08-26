#!/usr/bin/env bash

function clear_pure () {
  local printf_type;
  local echo_type;
  local clear_bin;
  printf_type="$(command type -ta printf)";
  echo_type="$(command type -ta echo)";
  clear_bin="$(which_bin 'clear')";

  if [[ ${echo_type} =~ builtin ]]; then
    builtin echo -ne "\ec";
  elif [[ ${printf_type} =~ builtin ]]; then
    builtin printf "\033c";
  elif [[ -n ${clear_bin} ]]; then
    eval "${clear_bin}";
  fi
  return 0;
}

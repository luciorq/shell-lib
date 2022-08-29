#!/usr/bin/env bash

# wrapper around check_installed
#function require () {
#  local cmd_str;
#  cmd_str="${1}";
#  check_installed "${cmd_str}" "${@:2}";
#
#  return;
#}

# Kill execution with error message if the program is not available
# + Can also be tested for functionality, by passing an argument
# + string that can safely returns values for program proporly
# + installed and functional
# @param 1 Name of the invocation command
# @param 2:+ Arguments for checking if installed program is functional
# + Default: '--version'
function require () {
  local cmd_str;
  local cmd_bin;
  local cmd_res;
  local full_cmd;
  cmd_str="${1}";
  cmd_bin="$(which_bin "${cmd_str}")";
  if [[ -z ${cmd_bin} ]]; then
    exit_fun "'${cmd_str}' executable not found in '\${PATH}'";
    return 1;
  fi

  if [[ ${#} -eq 1 ]]; then
    cmd_res="$( "${cmd_bin}" --version 2>&1 || builtin echo -ne '' )";
    full_cmd="${cmd_bin} --version";
  else
    cmd_res="$( "${cmd_bin}" "${@:2}" 2>&1 || builtin echo -ne '' )";
    full_cmd="${cmd_bin} ${*:2}";
  fi

  if [[ -n ${cmd_res} ]]; then
    builtin echo -ne "${cmd_bin}";
  else
    exit_fun "'${full_cmd}' can't be executed";
    return 1;
  fi
  return 0;
}

#!/usr/bin/env bash

# kill execution with error message if the program is not available
function check_installed () {
  local cmd_str;
  local cmd_args_str;
  local cmd_args_exec;
  local avail_res;
  local cmd_res;
  local cmd_bin;
  local full_cmd;
  cmd_str="$1";
  cmd_args_str="${@: 2}";
  
  if [[ ! -n "${cmd_args_str}" ]]; then
    cmd_args_exec="--version";
  else
    cmd_args_exec="${cmd_args_str}";
  fi

  if [[ ! -n "${cmd_args_str}" ]]; then
    local cmd_args_arr
    declare -a cmd_args_arr=($@);
    cmd_args_exec="${cmd_args_arr[@]:1}";
  fi

  if [[ ! -n "${cmd_args_str}" && ! -n "${cmd_args_exec}" ]]; then
    cmd_args_exec="--version";
  fi


  avail_res="$(is_available ${cmd_str})";     
  if [[ "${avail_res}" == false ]]; then
    return 1;
  fi
  cmd_bin="$(which_bin ${cmd_str})";
  cmd_res=$( "${cmd_bin}" ${cmd_args_exec} 2> /dev/null || echo -ne '' );
  if [[ -n "${cmd_res}" ]]; then
    echo -ne "${cmd_bin}";
    return 0;
  fi
  if [[ ! -n "${cmd_bin}" ]]; then
    cmd_bin="${cmd_str}";
  fi
  if [[ -n "${cmd_args_str}" ]]; then
    full_cmd="${cmd_bin} ${cmd_args_str}";  
  else
    full_cmd="${cmd_str}";
  fi
  if [[ ! -n "${cmd_res}" ]]; then
    # TODO luciorq cli_* color variable and bin names.
    >&2 echo -ne "'${full_cmd}' can't be executed.\n";
    return 1;
  fi
  return 0;
}

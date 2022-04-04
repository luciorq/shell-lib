#!/usr/bin/env bash

# Kill execution with error message if the program is not available
# + Can also be tested for functionality, by passing an argument
# + string that can safely returns values for program proporly
# + installed and functional
# @param 1 Name of the invocation command
# @param 2:+ Arguments for checking if installed program is functional
# + Default: '--version'
function check_installed () {
  local cmd_str;
  local cmd_args_str;
  local cmd_args_exec;
  local avail_res;
  local cmd_res;
  local cmd_bin;
  local full_cmd;
  local cmd_args_arr;
  cmd_str="$1";
  cmd_args_str="${@:2}";

  # Check if any argument is passed to check program
  # + sets --version as default
  if [[ -z "${cmd_args_str}" ]]; then
    cmd_args_exec="--version";
  else
    cmd_args_exec="${cmd_args_str}";
  fi

  if [[ -z "${cmd_args_str}" ]]; then
    declare -a cmd_args_arr=( $@ );
    cmd_args_exec="${cmd_args_arr[@]:1}";
  else
    declare -a cmd_args_arr=();
  fi

  if [[ -z "${cmd_args_str}" && -z "${cmd_args_exec}" ]]; then
    cmd_args_exec="--version";
  fi

  avail_res=$(is_available "${cmd_str}");
  if [[ "${avail_res}" == false ]]; then
    # This step already has an error message from is_available
    # + if avail_res == false
    return 1;
  fi
  cmd_bin=$(which_bin "${cmd_str}");
  cmd_res=$( "${cmd_bin}" ${cmd_args_exec} 2> /dev/null || builtin echo -ne '' );

  if [[ -n "${cmd_res[@]}" ]]; then
    builtin echo -ne "${cmd_bin}";
    return 0;
  fi
  if [[ -z "${cmd_bin}" ]]; then
    cmd_bin="${cmd_str}";
  fi
  if [[ -n "${cmd_args_str[@]}" ]]; then
    full_cmd="${cmd_bin} ${cmd_args_str[@]}";
  elif [[ -n "${cmd_args_exec[@]}" ]]; then
    full_cmd="${cmd_bin} ${cmd_args_exec[@]}";
  else
    full_cmd="${cmd_str}";
  fi
  if [[ -z "${cmd_res}" ]]; then
    # TODO luciorq Add cli_* color variable and bin names.
    builtin echo >&2 -ne "'${full_cmd}' can't be executed.\n";
    return 1;
  fi
  return 0;
}

#!/usr/bin/env bash
# shellcheck shell=bash

# Run a command on a remote host through ssh
function exec_remote () {
  \builtin local _usage="${0} <HOST> '<COMMAND>'";
  \builtin unset _usage;
  \builtin local _debug_var;
  _debug_var="${DEBUG:-false}"
  if [[ "${_debug_var}" == true ]]; then
    \builtin set -o xtrace;
  fi
  \builtin local host_target;
  \builtin local ssh_bin;
  \builtin local var_res;

  host_target="${1:-}";

  if [[ -z "${host_target}" ]]; then
    exit_fun "Invalid execution.\nUsage: ${_usage}\n";
    \builtin return 1;
  fi
  ssh_bin="$(require 'ssh')";

  var_res="$("${ssh_bin}" -t "${host_target}" "${@:2}")";

  \builtin echo "${var_res}";
  \builtin return 0;
}

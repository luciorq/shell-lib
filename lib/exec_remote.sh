#!/usr/bin/env bash
# shellcheck shell=bash

# Run a command on a remote host through ssh
function exec_remote () {
  local _usage="${0} <HOST> '<COMMAND>'";
  unset _usage;
  local _debug_var="${DEBUG:-false}";
  [[ "${_debug_var}" == true ]] && set -o xtrace;
  local host_target;
  local ssh_bin;
  local var_res;

  host_target="${1}";
  ssh_bin="$(require 'ssh')";

  # builtin echo -ne "";
  var_res="$("${ssh_bin}" -t "${host_target}" "${@:2}")";

  builtin echo "${var_res}";
  return 0;
}

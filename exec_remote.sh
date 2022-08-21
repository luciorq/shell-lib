#!/usr/bin/env bash
# shellcheck shell=bash

# Description for exec_remote
function exec_remote () {
  local _debug_var="${DEBUG:-false}";
  [[ "${_debug_var}" == true ]] && set -o xtrace;
  local _usage="${0} <HOST> '<COMMAND>'";
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

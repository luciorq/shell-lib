#!/usr/bin/env bash

# Starts a new Zellij session or attaches to an existing one.
# + If no session name is provided, it will list available sessions.
# + This function pairs well with the alias `alias zj='zellij_fun'`.
# Usage:
#   zj [session_name]
function zellij_fun () {
  \builtin local session_name;
  \builtin local zellij_bin;
  zellij_bin="$(require 'zellij')";
  if [[ -z ${zellij_bin} ]]; then
    exit_fun "Zellij is not installed or not found in PATH.";
    \builtin return 1;
  fi
  # if more than 1 argument is provided, print usage and exit
  if [[ "${#}" -gt 1 ]]; then
    exit_fun 'Only one argument is allowed.';
    \builtin return 1;
  fi
  session_name="${1:-}";
  if [[ -z "${session_name}" ]]; then
    "${zellij_bin}" list-sessions;
  else
    "${zellij_bin}" attach --create "${session_name}";
  fi
  \builtin return 0;
}
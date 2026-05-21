#!/usr/bin/env bash

function lsperm () {
  list_permission "${@}";
  \builtin return 0;
}

# List files, or directories, with permission octal triplets.
function list_permission () {
  \builtin local stat_bin;
  stat_bin="$(require 'stat')";
  if [[ -z "${stat_bin}" ]]; then
    exit_fun "'stat' command not found";
    \builtin return 1;
  fi
  if [[ -z "${1:-}" ]]; then
    "${stat_bin}" -c "%a %n" "${1:-.}";
  else
    "${stat_bin}" -c "%a %n" "${@}";
  fi
  \builtin return 0;
}
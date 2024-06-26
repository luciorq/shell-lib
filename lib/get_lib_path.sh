#!/usr/bin/env bash

function get_lib_path () {
  \builtin local lib_path;
  \builtin local lib_name;
  lib_name="${1:-}";
  if [ -d "${HOME}/projects/${lib_name}" ]; then
    lib_path="${HOME}/projects/${lib_name}";
  elif [ -d "${XDG_LIB_HOME}/${lib_name}" ]; then
    lib_path="${XDG_LIB_HOME}/${lib_name}";
  elif [ -d "${HOME}/.local/lib/${lib_name}" ]; then
    lib_path="${HOME}/.local/lib/${lib_name}";
  else
    \builtin echo >&2 -ne "Lib path '${lib_name}' not available\n";
    \builtin return 1;
  fi
  \builtin echo -ne "${lib_path}";
  \builtin return 0;
}

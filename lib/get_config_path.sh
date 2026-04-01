#!/usr/bin/env bash

# Retrieve private configuration path
function get_config_path () {
  \builtin local _usage;
  _usage="${0} [--priv | -p] [<private_dir>]";
  \builtin unset _usage;
  \builtin local cfg_path;
  \builtin local private_dir;

  \builtin local first_arg;
  first_arg="${1:-}";


  if [[ ${first_arg} == --priv ]] || [[ ${first_arg} == -p ]]; then
    private_dir="$(get_config env priv)";
    cfg_path="${XDG_CONFIG_HOME:-${HOME}/.config}/${private_dir}";
  else
    private_dir="${first_arg}";
    cfg_path="${_LOCAL_CONFIG:-${XDG_CONFIG_HOME:-${HOME}/.config}/${private_dir}}";
  fi
  \builtin echo -ne "${cfg_path}";
  \builtin return 0;
}

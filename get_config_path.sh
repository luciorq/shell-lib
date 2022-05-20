#!/usr/bin/env bash

# Retrieve private configuration path
function get_config_path () {
  local cfg_path;
  local private_dir;
  if [[ ${1} == --priv ]] || [[ ${1} == -p ]]; then
    private_dir="$(get_config env priv)";
    cfg_path="${XDG_CONFIG_HOME:-${HOME}/.config}/${private_dir}";
  else
    private_dir="${1}";
    cfg_path="${_LOCAL_CONFIG:-${XDG_CONFIG_HOME:-${HOME}/.config}/${private_dir}}";
  fi
  builtin echo -ne "${cfg_path}";
  return 0;
}

#!/usr/bin/env bash

# Retrieve private configuration path
function get_config_path () {
  local cfg_path;
  local private_dir;
  private_dir="${1}";
  cfg_path="${_LOCAL_CONFIG:-${XDG_CONFIG_HOME:-${HOME}/.config}/${private_dir}}";
  builtin echo -ne "${cfg_path}";
  return 0;
}

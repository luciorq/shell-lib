#!/usr/bin/env bash

# Retrieve configuration from
# + default personal configuration files
# + Curretly only working with YAML files;
# @param --priv | -p Search var file on private path.
function get_config () {
  \builtin local _usage;
  _usage="Usage: ${0} <{--priv|-p]>";
  \builtin unset -v _usage;
  \builtin local cfg_dir;
  \builtin local file_base_name;
  \builtin local file_ext;
  \builtin local var_file;
  \builtin local argv;
  if [[ "${1:-}" == "--priv" ]] || [[ "${1:-}" == "-p" ]]; then

    \builtin declare -a argv;
    argv=("${@:3}");
    file_base_name="${2:-}";
    cfg_dir="$(get_config_path --priv)";
  else
    \builtin declare -a argv;
    argv=("${@:2}");
    file_base_name="${1:-}";
    cfg_dir="$(get_config_path)";
  fi
  file_ext='yaml';
  var_file="${cfg_dir}/vars/${file_base_name}.${file_ext}";
  if [[ ! -f ${var_file} ]]; then
    file_ext="yml";
    var_file="${cfg_dir}/vars/${file_base_name}.${file_ext}";
  fi
  if [[ ! -f ${var_file} ]]; then
    exit_fun "'${var_file}' no such file.";
    \builtin return 1;
  fi
  parse_yaml "${var_file}" main "${argv[@]}";
  \builtin return 0;
}

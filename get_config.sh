#!/usr/bin/env bash

# Retrieve configuration from
# + default personal configuration files
# + Curretly only working with YAML files;
function get_config () {
  local cfg_dir;
  local file_base_name;
  local file_ext;
  local var_file;
  cfg_dir="$(get_config_path)";
  file_base_name="${1}";
  file_ext='yaml';
  var_file="${cfg_dir}/vars/${file_base_name}.${file_ext}";
  if [[ ! -f ${var_file} ]]; then
    file_ext="yml";
    var_file="${cfg_dir}/vars/${file_base_name}.${file_ext}";
  fi
  if [[ ! -f ${var_file} ]]; then
    builtin echo >&2 -ne "Error: '${var_file}' no such file.\n";
    return 1;
  fi
  parse_yaml "${var_file}" default "${@:2}";
}

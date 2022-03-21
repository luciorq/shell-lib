#!/usr/bin/env bash

# Retrieve configuration from
# + default personal configuration files
# + Curretly only working with YAML files;
function get_config () {
  local cfg_dir;
  local file_base_name;
  local file_ext;
  local var_file;
  local full_args_arr;
  local args_arr;
  cfg_dir="$(get_config_path)";
  file_base_name="$1";
  file_ext='yaml';
  declare -a full_args_arr=($@);
  declare -a args_arr=( ${full_args_arr[@]:1} );
  var_file="${cfg_dir}/vars/${file_base_name}.${file_ext}";
  parse_yaml "${var_file}" default ${args_arr[@]};
}

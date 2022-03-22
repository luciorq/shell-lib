#!/usr/bin/env bash

# Extract variables from YAML a file
function parse_yaml () {
  local yq_bin;
  local ruby_bin;
  local method;
  local args_arr;
  yq_bin="$(which_bin 'yq')";
  ruby_bin="$(which_bin 'ruby')";
  declare -a args_arr=($@);
  method='';
  if [[ -n ${yq_bin} ]]; then
    method='yq';
  elif [[ -n ${ruby_bin} ]]; then
    method='ruby';
  fi
  case "${method}" in
    yq)     __parse_yaml_yq ${args_arr[@]};;
    ruby)   __parse_yaml_ruby ${args_arr[@]};;
    *) builtin echo >&2 -ne "No method available for parsing YAML.\n"; return 1;;
  esac
}

function __parse_yaml_ruby () {
  local ruby_bin;
  local ruby_script;
  local yaml_path;
  local args_arr;
  local yaml_levels level;
  declare -a args_arr=($@);
  declare -a yaml_levels=(${args_arr[@]:1});
  ruby_bin="$(which_bin 'ruby')";
  yaml_path="$1";
  ruby_script="var_res=YAML::load(open(ARGV.first).read)";
  for level in ${yaml_levels[@]}; do
    ruby_script="${ruby_script}['${level}']";
  done
  ruby_script="${ruby_script}; if var_res.class == Hash; puts YAML::dump(var_res) else puts var_res end;";
  # echo $ruby_script;
  "${ruby_bin}" -ryaml -e "${ruby_script}" "${yaml_path}";
}

function __parse_yaml_yq () {
  local yq_bin;
  local yq_str;
  local yaml_path;
  local args_arr;
  local yaml_levels level;
  local level_str;
  declare -a args_arr=($@);
  declare -a yaml_levels=(${args_arr[@]:1});
  yq_bin="$(which_bin 'yq')";
  yaml_path="$1";
  level_str='';
  for level in ${yaml_levels[@]}; do
    level_str="${level_str}.${level}";
  done
  if [[ -z ${level_str} ]]; then
    level_str='.'
  fi
  yq_str="... comments=\"\" | ${level_str} | ( select( has(0) ) | .[]) // ."
  "${yq_bin}" eval --no-doc "${yq_str}" "${yaml_path}";
}

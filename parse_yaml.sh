#!/usr/bin/env bash

# Extract variables from YAML a file
function parse_yaml () {
  local yq_bin;
  local ruby_bin;
  local py3_bin py_bin;
  local method;
  local args_arr;
  yq_bin="$(which_bin 'yq')";
  ruby_bin="$(which_bin 'ruby')";
  py3_bin="$(which_bin 'python3')";
  py_bin="$(which_bin 'python')";

  declare -a args_arr=($@);
  method='';
  if [[ -n ${yq_bin} ]]; then
    method='yq';
  elif [[ -n ${ruby_bin} ]]; then
    method='ruby';
  elif [[ -n ${py3_bin} || -n ${py_bin} ]]; then
    method='python';
  fi
  case "${method}" in
    yq)     __parse_yaml_yq ${args_arr[@]};;
    ruby)   __parse_yaml_ruby ${args_arr[@]};;
    python) __parse_yaml_python ${args_arr[@]};;
    *) builtin echo >&2 -ne "No method available for parsing YAML.\n"; return 1;;
  esac
}

function __parse_yaml_ruby () {
  local ruby_bin;
  local ruby_script;
  local yaml_path;
  local args_arr;
  local yaml_levels level;
  local int_regex;
  declare -a args_arr=($@);
  declare -a yaml_levels=(${args_arr[@]:1});
  ruby_bin="$(which_bin 'ruby')";
  yaml_path="$1";
  ruby_script="var_res=YAML::load(open(ARGV.first).read)";
  int_regex='^[0-9]+$';
  for level in ${yaml_levels[@]}; do
    if [[ ${level} =~ ${int_regex} ]]; then
      ruby_script="${ruby_script}[${level}]";
    else
      ruby_script="${ruby_script}['${level}']";
    fi
  done
  ruby_script="${ruby_script}; if var_res.class == Hash; puts YAML::dump(var_res) else puts var_res end;";
  "${ruby_bin}" -ryaml -e "${ruby_script}" "${yaml_path}";
  return 0;
}

function __parse_yaml_yq () {
  local yq_bin;
  local yq_str;
  local yaml_path;
  local args_arr;
  local yaml_levels level;
  local levels_str;
  declare -a args_arr=($@);
  declare -a yaml_levels=(${args_arr[@]:1});
  yq_bin="$(which_bin 'yq')";
  yaml_path="$1";
  levels_str='';
  for level in ${yaml_levels[@]}; do
    levels_str="${levels_str}.${level}";
  done
  if [[ -z ${levels_str} ]]; then
    levels_str='.'
  fi
  yq_str="... comments=\"\" | ${levels_str} | ( select( has(0) ) | .[]) // ."
  "${yq_bin}" eval --no-doc "${yq_str}" "${yaml_path}";
  return 0;
}

function __parse_yaml_python () {
  local py_bin;
  local yaml_path;
  local args_arr;
  local yaml_levels level;
  local levels_str;
  local py_script;
  local int_regex;
  declare -a args_arr=($@);
  declare -a yaml_levels=(${args_arr[@]:1});
  py_bin="$(which_bin 'python3')";
  if [[ -z ${py_bin} ]]; then
    py_bin="$(which_bin 'python')";
  fi
  yaml_path="${1}";
  levels_str='';
  int_regex='^[0-9]+$';
  for level in ${yaml_levels[@]}; do
    if [[ ${level} =~ ${int_regex} ]]; then
      levels_str="${levels_str}[${level}]";
    else
      levels_str="${levels_str}['${level}']";
    fi
  done
  py_script="import yaml;x = yaml.safe_load(open('${yaml_path}', 'r'))";
  py_script="${py_script}${levels_str}";
  py_script="${py_script}; print(x) if isinstance(x, str) else print(*x, sep ='\n') if isinstance(x, list) else print(yaml.dump(x)) if isinstance(x, dict) else False;";
  "${py_bin}" -c "${py_script}";
  return 0;
}


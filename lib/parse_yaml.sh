#!/usr/bin/env bash

# Extract variables from YAML a file
function parse_yaml () {
  local yq_bin;
  local ruby_bin;
  local py3_bin py_bin;
  local method;
  local file_path;
  yq_bin="$(which_bin 'yq')";
  ruby_bin="$(which_bin 'ruby')";
  py3_bin="$(which_bin 'python3')";
  py_bin="$(which_bin 'python')";
  file_path="${1}";
  if [[ ! -f ${file_path} ]]; then
    exit_fun "File '${file_path}' does not exist";
    return 1;
  fi
  method='';
  if [[ -n ${yq_bin} ]]; then
    method='yq';
  elif [[ -n ${ruby_bin} ]]; then
    method='ruby';
  elif [[ -n ${py3_bin} || -n ${py_bin} ]]; then
    method='python';
  fi
  case "${method}" in
    yq)     __parse_yaml_yq "${@}";;
    ruby)   __parse_yaml_ruby "${@}";;
    python) __parse_yaml_python "${@}";;
    *)
      exit_fun 'No method available for parsing YAML.';
      return 1;
    ;;
  esac
}

function __parse_yaml_ruby () {
  local ruby_bin;
  local ruby_script;
  local yaml_path;
  local _level;
  local int_regex;
  local yaml_res;
  ruby_bin="$(which_bin 'ruby')";
  yaml_path="${1}";
  ruby_script="var_res=YAML::load(open(ARGV.first).read)";
  int_regex='^[0-9]+$';
  for _level in "${@:2}"; do
    if [[ ${_level} =~ ${int_regex} ]]; then
      ruby_script="${ruby_script}[${_level}]";
    else
      ruby_script="${ruby_script}['${_level}']";
    fi
  done
  ruby_script="${ruby_script}; if var_res.class == Hash; puts YAML::dump(var_res) elsif var_res.class == Array; for item in var_res; puts YAML::dump(item) end; else puts var_res end;";
  yaml_res=$(
    "${ruby_bin}" -ryaml -e "${ruby_script}" "${yaml_path}" \
      | grep -v '^---'
  );
  builtin echo -ne "${yaml_res}";
  return 0;
}

function __parse_yaml_yq () {
  local yq_bin;
  local yq_str;
  local yaml_path;
  local _level;
  local levels_str;
  local yaml_res;
  yq_bin="$(which_bin 'yq')";
  yaml_path="${1}";
  levels_str='';
  for _level in "${@:2}"; do
    levels_str="${levels_str}.${_level}";
  done
  if [[ -z ${levels_str} ]]; then
    levels_str='.'
  fi
  yq_str="... comments=\"\" | ${levels_str} | ( select( has(0) ) | .[]) // ."
  yaml_res=$(
    "${yq_bin}" eval --no-doc "${yq_str}" "${yaml_path}"
  );
  if [[ ${yaml_res} == null ]]; then
    yaml_res='\n';
  fi
  builtin echo -ne "${yaml_res}";
  return 0;
}

function __parse_yaml_python () {
  local py_bin;
  local yaml_path;
  local _level;
  local levels_str;
  local py_script;
  local int_regex;
  local module_res;
  py_bin="$(which_bin 'python3')";
  if [[ -z ${py_bin} ]]; then
    py_bin="$(which_bin 'python')";
  fi

  if [[ -z ${py_bin} ]]; then
    exit_fun "'python' is not available.";
    return 1;
  fi

  yaml_path="${1}";
  levels_str='';
  int_regex='^[0-9]+$';
  for _level in "${@:2}"; do
    if [[ ${_level} =~ ${int_regex} ]]; then
      levels_str="${levels_str}[${_level}]";
    else
      levels_str="${levels_str}['${_level}']";
    fi
  done
  module_res=$("${py_bin}" -c 'import yaml' 2> /dev/null);
  if [[ $? -eq 1 ]]; then
    exit_fun 'Python {yaml} module is not installed.';
    return 1;
  fi
  py_script="import yaml;x = yaml.safe_load(open('${yaml_path}', 'r'))";
  py_script="${py_script}${levels_str}";
  py_script="${py_script}; print(x) if isinstance(x, str) else print(*x, sep ='\n') if isinstance(x, list) else print(yaml.dump(x)) if isinstance(x, dict) else False;";
  module_res=$( "${py_bin}" -c "${py_script}" 2>&1 );
  if [[ ${module_res} =~ KeyError: ]]; then
    builtin echo -ne '\n';
    return 0;
  fi
  builtin echo -ne "${module_res}";
  return 0;
}

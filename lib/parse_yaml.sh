#!/usr/bin/env bash

# Extract variables from YAML a file
function parse_yaml () {
  \builtin local _usage;
  _usage="Usage: ${0} <FILE_NAME> [<KEY_1>...<KEY_N>]";
  \builtin unset _usage;
  \builtin local yq_bin;
  \builtin local ruby_bin;
  \builtin local py3_bin;
  \builtin local py_bin;
  \builtin local method;
  \builtin local file_path;
  yq_bin="$(which_bin 'yq')";
  ruby_bin="$(which_bin 'ruby')";
  py_bin="$(which_bin 'python')";
  py3_bin="$(which_bin 'python3')";
  file_path="${1:-}";
  if [[ ! -f ${file_path} ]]; then
    exit_fun "File '${file_path}' does not exist";
    \builtin return 1;
  fi
  method='';
  if [[ -n ${yq_bin} ]]; then
    method='yq';
  elif [[ -n ${ruby_bin} ]]; then
    method='ruby';
  elif [[ -n ${py3_bin} || -n ${py_bin} ]]; then
    # TODO: @luciorq Add check for python yaml module installed
    # + on the top level, currently it is only checked inside the
    # python based functions.
    # + e.g. `python -c 'import yaml'`
    method='python';
  fi
  case "${method}" in
    yq)     __parse_yaml_yq "${@}";;
    ruby)   __parse_yaml_ruby "${@}";;
    python) __parse_yaml_python "${@}";;
    *)
      exit_fun 'No method available for parsing YAML.';
      \builtin return 1;
    ;;
  esac
}

function __parse_yaml_ruby () {
  \builtin local ruby_bin;
  \builtin local ruby_script;
  \builtin local yaml_path;
  \builtin local _level;
  \builtin local int_regex;
  \builtin local yaml_res;
  ruby_bin="$(which_bin 'ruby')";
  yaml_path="${1:-}";
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
  \builtin echo -ne "${yaml_res}";
  \builtin return 0;
}

# TODO: @luciorq need to test if the right {yq} binary is used.
# + e.g. in conda-forge there is `yq` and `go-yq` packages.
# + `yq` is a python library wrapping `jq` and `pyyaml`.
# + `go-yq` is the right one, it is a Go based single binary. Also found at:
# + <https://github.com/mikefarah/yq>
function __parse_yaml_yq () {
  \builtin local yq_bin;
  \builtin local yq_str;
  \builtin local yaml_path;
  \builtin local _level;
  \builtin local levels_str;
  \builtin local yaml_res;
  yq_bin="$(which_bin 'yq')";
  yaml_path="${1:-}";
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
  \builtin echo -ne "${yaml_res}";
  \builtin return 0;
}

function __parse_yaml_python () {
  \builtin local py_bin;
  \builtin local yaml_path;
  \builtin local _level;
  \builtin local levels_str;
  \builtin local py_script;
  \builtin local int_regex;
  \builtin local module_res;
  \builtin local has_yaml_module;
  py_bin="$(which_bin 'python')";
  has_yaml_module='';

  if [[ -n ${py_bin} ]]; then
    module_res=$("${py_bin}" -c 'import yaml' 2> /dev/null);
    if [[ ${?} -eq 0 ]]; then
      has_yaml_module='true';
    fi
  fi

  if [[ -z ${py_bin} ]]; then
    py_bin="$(which_bin 'python3')";
    if [[ -n ${py_bin} ]]; then
      module_res=$("${py_bin}" -c 'import yaml' 2> /dev/null);
      if [[ ${?} -eq 0 ]]; then
        has_yaml_module='true';
      fi
    fi
  fi

  if [[ -z ${py_bin} ]]; then
    exit_fun "'python' is not available.";
    \builtin return 1;
  fi

  if [[ -z ${has_yaml_module} ]]; then
    exit_fun 'Python {yaml} module is not installed.';
    \builtin return 1;
  fi

  yaml_path="${1:-}";
  levels_str='';
  int_regex='^[0-9]+$';
  for _level in "${@:2}"; do
    if [[ ${_level} =~ ${int_regex} ]]; then
      levels_str="${levels_str}[${_level}]";
    else
      levels_str="${levels_str}['${_level}']";
    fi
  done

  py_script="import yaml;x = yaml.safe_load(open('${yaml_path}', 'r'))";
  py_script="${py_script}${levels_str}";
  py_script="${py_script}; print(x) if isinstance(x, str) else [print(yaml.dump(i)) for i in x] if isinstance(x, list) else print(yaml.dump(x)) if isinstance(x, dict) else False;";
  module_res=$( "${py_bin}" -c "${py_script}" 2>&1 );
  if [[ ${module_res} =~ KeyError: ]]; then
    \builtin echo -ne '\n';
    \builtin return 0;
  fi
  \builtin echo -ne "${module_res}";
  \builtin return 0;
}

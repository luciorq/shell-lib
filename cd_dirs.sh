#!/usr/bin/env bash

# Functions to change predefined paths

function cd_prj () {
  local prj_path;
  prj_path="${_LOCAL_PROJECT:-${HOME}/projects}";
  __cd_dir "${prj_path}";
}

function cd_cfg () {
  local cfg_path;
  cfg_path="${XDG_CONFIG_HOME:-${HOME}/.config}";
  __cd_dir "${cfg_path}";
}

function __cd_dir () {
  local dir_arg;
  local dir_path;
  local realpath_bin;
  dir_arg=("$@");
  dir_path=( $(builtin eval builtin echo -ne ${dir_arg}) );
  
  dir_path="${dir_path[0]}";
  realpath_bin="$(which_bin 'realpath')";
  if [[ -n ${realpath_bin} ]]; then
    dir_path=( $("${realpath_bin}" "${dir_path}") );
  fi

  dir_path="${dir_path[0]}";
  if [[ -d ${dir_path} ]]; then
    builtin cd "${dir_path}";
    if [[ $? -eq 0 ]]; then
      builtin echo -ne "Changing working directory to: [${dir_path}]\n";
    fi
  elif [[ -f ${dir_path} ]]; then
    builtin echo >&2 -ne "[$dir_path] is not a directory\n";
  else
    builtin echo >&2 -ne "Directory don't exist [$dir_path]\n";
    return 0;
  fi
}

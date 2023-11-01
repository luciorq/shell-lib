#!/usr/bin/env bash

function type_color () {
  local bat_bin;
  bat_bin="$(which_bin 'bat')";
  if [[ -z ${bat_bin} ]]; then
    builtin type "${@}";
  else
    builtin type "${@}" \
      | bat_fun \
        -l 'bash' \
        --style=plain --paging=never \
        --theme 'gruvbox-dark';
  fi
  return 0;
}

function cat_color () {
  local bat_bin;
  local bat_filename;
  local cat_bin;
  local _arg;
  cat_bin="$(require 'cat')";
  if [[ -z ${cat_bin} ]]; then
    return 1;
  fi
  bat_bin="$(which_bin 'bat')";
  if [[ -z ${bat_bin} ]]; then
    "${cat_bin}" "${@}";
    return 0;
  fi
  bat_filename='';
  for _arg in "${@}"; do
    if [[ -z ${bat_filename} && -f ${_arg} ]]; then
      declare -a bat_filename=(
        --file-name
        "${_arg}"
      );
    fi
  done
  if [[ -d ${1} ]]; then
    "${cat_bin}" "${@}";
    return 0;
  fi
  "${cat_bin}" "${@}" \
    | bat_fun \
      --style=plain --paging=never \
      --theme 'gruvbox-dark' "${bat_filename[@]}" \
      --color auto;
  return 0;
}


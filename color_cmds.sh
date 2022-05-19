#!/usr/bin/env bash

function type_color () {
  local bat_bin;
  bat_bin="$(which_bin 'bat')";
  if [[ -z ${bat_bin} ]]; then
    builtin type "${@}";
  else
    builtin type "${@}" \
      | bat_fun \
        -l 'bash' -p --paging 'never' \
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
  "${cat_bin}" "${@}" \
    | bat_fun \
      -p --paging 'never' \
      --theme 'gruvbox-dark' "${bat_filename[@]}" \
      --color auto;
  return 0;
}


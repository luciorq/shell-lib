#!/usr/bin/env bash

function type_color () {
  builtin local bat_bin;
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
  builtin local bat_bin;
  builtin local bat_filename;
  builtin local cat_bin;
  builtin local _arg;
  cat_bin="$(require 'cat')";
  if [[ -z ${cat_bin} ]]; then
    builtin return 1;
  fi
  bat_bin="$(which_bin 'bat')";
  if [[ -z ${bat_bin} ]]; then
    "${cat_bin}" "${@}";
    builtin return 0;
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
  if [[ -d ${1:-} ]]; then
    "${cat_bin}" "${@}";
    builtin return 0;
  fi
  "${cat_bin}" "${@}" \
    | bat_fun \
      --style=plain --paging=never \
      --theme 'gruvbox-dark' "${bat_filename[@]}" \
      --color auto;
  builtin return 0;
}


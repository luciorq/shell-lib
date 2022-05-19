#!/usr/bin/env bash

function type_color () {
  local bat_bin;
  local bat_res;
  bat_bin="$(which_bin 'bat')";
  bat_res="$("${bat_bin}" -V 2> /dev/null > /dev/null || builtin echo -ne "${?}")";
  if [[ -z ${bat_bin} || -n  ${bat_res} ]]; then
    builtin type "${@}";
  else
    builtin type "${@}" \
      | "${bat_bin}" \
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
  local bat_res;

  cat_bin="$(require 'cat')";
  if [[ -z ${cat_bin} ]]; then
    return 1;
  fi

  bat_bin="$(which_bin 'bat')";

  bat_res="$("${bat_bin}" -V 2> /dev/null > /dev/null || builtin echo -ne "${?}")";

  if [[ -n ${bat_res} || -z ${bat_bin} ]]; then
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
    | "${bat_bin}" \
    -p --paging 'never' \
    --theme 'gruvbox-dark' "${bat_filename[@]}" \
    --color auto;
  return 0;
}


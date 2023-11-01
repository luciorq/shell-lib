#!/usr/bin/env bash

function bat_fun () {
  local bat_bin;
  local cat_bin;
  local bat_avail;
  bat_bin="$(which_bin 'bat')";
  if [[ -z ${bat_bin} ]]; then
    bat_bin="$(which_bin 'batcat')";
  fi
  if [[ -n ${bat_bin} ]]; then
    bat_avail="$(
      "${bat_bin}" -V 2> /dev/null > /dev/null || builtin echo -ne "${?}"
    )";
  fi
  cat_bin="$(which_bin 'cat')";
  if [[ -n ${bat_bin} && -z ${bat_avail} ]]; then
    "${bat_bin}" "${@}" --theme 'gruvbox-dark';
  else
    "${cat_bin}";
  fi
  return 0;
}

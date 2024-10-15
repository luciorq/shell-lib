#!/usr/bin/env bash

function exa_fun () {
  \builtin local ls_bin;
  \builtin local exa_bin;
  \builtin local exa_res;
  ls_bin="$(require 'ls')";
  exa_bin="$(which_bin 'eza')";
  exa_res="$("${exa_bin}" -v 2> /dev/null > /dev/null || builtin echo -ne "${?:-1}")";
  if [[ -n ${exa_res} || -z ${exa_bin} ]]; then
    "${ls_bin}" "${@:-}";
    \builtin return 0;
  fi
  "${exa_bin}" "${@:-}";
  \builtin return 0;
}

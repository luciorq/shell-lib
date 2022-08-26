#!/usr/bin/env bash

function exa_fun () {
  local ls_bin;
  local exa_bin;
  local exa_res;
  ls_bin="$(require 'ls')";
  exa_bin="$(which_bin 'exa')";

  exa_res="$("${exa_bin}" -v 2> /dev/null > /dev/null || builtin echo -ne "${?}")";


  if [[ -n ${exa_res} || -z ${exa_bin} ]]; then
    "${ls_bin}" "${@}";
    return 0;
  fi

  "${exa_bin}" "${@}";

  return 0;

}

#!/usr/bin/env bash

# zoxide aware `cd` replacement
# + with support for `cd -` and `cd +`
function cd_fun () {
  local zoxide_bin;
  zoxide_bin="$(which_bin 'zoxide')";
  if [[ -n ${zoxide_bin} ]] && [[ $(builtin type -t z) == function ]]; then
    z "${@}";
  else
    builtin cd "${@}" || return 1;
  fi
  builtin return 0;
}
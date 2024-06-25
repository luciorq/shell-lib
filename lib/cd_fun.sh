#!/usr/bin/env bash

# zoxide aware `cd` replacement
# + with support for `cd -` and `cd +`
function cd_fun () {
  \builtin local zoxide_bin;
  zoxide_bin="$(which_bin 'zoxide')";
  if [[ -n ${zoxide_bin} ]] && [[ $(\builtin type -t z) != function ]] && [[ "${SHELL:-}" =~ bash$ ]]; then
    \builtin eval "$("${zoxide_bin}" init bash)";
  fi
  if [[ -n ${zoxide_bin} ]] && [[ $(\builtin type -t z) == function ]]; then
    z "${@}";
  else
    \builtin cd -- "${@}" || \builtin return 1;
  fi
  \builtin return 0;
}

#!/usr/bin/env bash

# zoxide aware `cd` replacement
# + with support for `cd -` and `cd +`
function cd_fun () {
  local zoxide_bin;
  zoxide_bin="$(which_bin 'zoxide')";
  if [[ -z ${zoxide_bin} ]]; then
    builtin cd "${@}";
  fi

  if [[ $(type -t z) == function ]]; then
    z "${@}";
  fi
  # TODO: @luciorq check if `z` function is defined
  builtin return 0;
}
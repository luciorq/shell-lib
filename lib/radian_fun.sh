#!/usr/bin/env bash

# Run Radian R prompt with some defaults
function radian_fun () {
  local r_bin;
  local py_bin;
  # local radian_bin;
  r_bin="$(which_bin 'R')";
  py_bin="$(which_bin 'python3')";
  # radian_bin="$(which_bin 'radian')";
  # if [[ -z ${radian_bin} ]];then
  #  exit_fun "'radian' is not available on '${PATH}'";
  #  return 1;
  # fi
  _IS_RADIAN=true "${py_bin}" -m radian \
    --r-binary="${r_bin}" \
    --profile="${HOME}/.config/radian/profile" \
    --global-history \
    --quiet \
    "${@}";
  return 0;
}

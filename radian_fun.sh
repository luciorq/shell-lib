#!/usr/bin/env bash

# Run Radian R prompt with some defaults
function radian_fun () {
  local r_bin;
  local radian_bin;
  r_bin="$(which_bin 'R')";
  radian_bin="$(which_bin 'radian')";
  if [[ -z ${radian_bin} ]];then
    exit_fun "'radian' is not available on '${PATH}'";
    return 1;
  fi
  _IS_RADIAN=true "${radian_bin}" \
    --r-binary="${r_bin}" \
    --profile="${HOME}/.config/radian/profile" \
    --global-history --quiet;
  return 0;
}

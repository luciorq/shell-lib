#!/usr/bin/env bash

# TODO: @luciorq This should definitely be deprecated.
# + Check new rust based R prompt that I don't recall the name of.
# Run Radian R prompt with some defaults
function radian_fun () {
  \builtin local r_bin;
  \builtin local py_bin;
  # \builtin local radian_bin;
  # r_bin="$(which_bin 'R')";
  py_bin="$(which_bin 'python3')";
  if [[ -z "${py_bin}" ]]; then
    py_bin="$(which_bin 'python')";
  fi
  if [[ -z "${py_bin}" ]]; then
    exit_fun "'python3' or 'python' is not available on '${PATH}'";
    \builtin return 1;
  fi
  # radian_bin="$(which_bin 'radian')";
  # if [[ -z "${radian_bin}" ]];then
  #  exit_fun "'radian' is not available on '${PATH}'";
  #  \builtin return 1;
  # fi
  # radian \
  _IS_RADIAN=true "${py_bin}" -m radian \
    --r-binary="${r_bin}" \
    --profile="${HOME}/.config/radian/profile" \
    --global-history \
    --quiet \
    "${@}";
  \builtin return 0;
}

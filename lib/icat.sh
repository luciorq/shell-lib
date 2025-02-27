#!/usr/bin/env bash

# Open images at the terminal
# + if kitty API is available use
# + icat kitten
function icat () {
  \builtin local bash_bin;
  \builtin local kitty_bin;
  bash_bin="$(which_bin 'bash')";
  kitty_bin="$(require 'kitty')";
  if [[ -z ${kitty_bin} ]]; then
    \builtin return 1;
  fi
  "${bash_bin}" "${kitty_bin}" +kitten icat "${@}";
  \builtin return 0;
}

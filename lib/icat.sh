#!/usr/bin/env bash

# Open images at the terminal
# + if kitty API is available use
# + icat kitten
function icat () {
  local bash_bin;
  local kitty_bin;
  bash_bin="$(which_bin 'bash')";
  kitty_bin="$(which_bin 'kitty')";
  "${bash_bin}" "${kitty_bin}" +kitten icat "${@}";
  return 0;
}

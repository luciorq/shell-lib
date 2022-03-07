#!/usr/bin/env bash

# Return the first executable on path, without failing
function which_bin () {
  local cmd_bin;
  cmd_bin=$( (which -a "$1" || echo -ne '') | head -1 );
  echo -ne "${cmd_bin}";
  return 0;
}


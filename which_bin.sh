#!/bin/env bash

# Return the first executable on path, without failing
function which_bin () {
  local cmd_bin
  cmd_bin=$( (which -a "$1" || echo -n "") | head -1 );
  echo "${cmd_bin}";
  return 0;
}


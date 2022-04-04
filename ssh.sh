#!/usr/bin/env bash

# Kitten Aware SSH connection
function ssh () {
  local ssh_bin;
  ssh_bin="$(require 'ssh')";
  if [[ ${TERM}  == xterm-kitty ]]; then
    TERM='xterm-256color' "${ssh_bin}" ${@:1};
    # kitty +kitten ssh ${@:1};
  else
    "${ssh_bin}" ${@:1};
  fi
}


#!/usr/bin/env bash

# Kitten Aware SSH connection
function ssh () {
  if [[ ${TERM}  == xterm-kitty ]]; then
    TERM='xterm-256color' ssh ${@};
    # kitty +kitten ssh ${@};
  else
    ssh ${@};
  fi
}


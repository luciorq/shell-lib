#!/usr/bin/env bash

# Kitten Aware SSH connection
function ssh_fun () {
  local ssh_bin;
  ssh_bin="$(require 'ssh')";
  if [[ ${_KITTY_SSH} == true ]]; then
    TERM='xterm-256color' "${ssh_bin}" "${@:1}";
  elif [[ ${TERM}  == xterm-kitty ]]; then
    if [[ -f ${HOME}/.local/share/kitty-ssh-kitten/kitty/bin/kitty ]]; then
      chmod +x "${HOME}/.local/share/kitty-ssh-kitten/kitty/bin/kitty";
    fi
    kitty +kitten ssh "${@:1}";
  else
    TERM='xterm-256color' "${ssh_bin}" "${@:1}";
  fi
}


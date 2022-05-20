#!/usr/bin/env bash

# Kitten Aware SSH connection
function ssh_fun () {
  local ssh_bin;
  local chmod_bin;
  ssh_bin="$(require 'ssh' '-V')";
  set -x;
  if [[ ${_KITTY_SSH} == true ]]; then
    TERM='xterm-256color' "${ssh_bin}" "${@:1}";
  elif [[ ${TERM}  == xterm-kitty ]]; then
    if [[ -f ${HOME}/.local/share/kitty-ssh-kitten/kitty/bin/kitty ]]; then
      chmod_bin="$(require 'chmod')";
      "${chmod_bin}" a+x "${HOME}/.local/share/kitty-ssh-kitten/kitty/bin/kitty";
      "${chmod_bin}" -R a+x "${HOME}/.local/share/kitty-ssh-kitten";
      "${chmod_bin}" a+x \
        "${HOME}/.local/share/kitty-ssh-kitten/shell-integration/bash/kitty.bash"
    fi
    kitty +kitten ssh "${@:1}";
  else
    _SSH_VAR='true' TERM='xterm-256color' "${ssh_bin}" "${@:1}";
  fi
  set +x;
  return 0;
}

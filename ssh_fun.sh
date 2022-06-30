#!/usr/bin/env bash

# Kitten Aware SSH connection
function ssh_fun () {
  local ssh_bin;
  local chmod_bin;
  ssh_bin="$(require 'ssh' '-V')";
  chmod_bin="$(require 'chmod')";
  set -x;
  if [[ ${_KITTY_SSH} == true ]]; then
    TERM='xterm-256color' "${ssh_bin}" "${@:1}";
  elif [[ ${TERM}  == xterm-kitty ]]; then
    if [[ -d ${HOME}/.local/share/kitty-ssh-kitten ]]; then
      "${chmod_bin}" a+x \
        "${HOME}/.local/share/kitty-ssh-kitten/kitty/bin/kitty" \
        || builtin echo -ne '';
      "${chmod_bin}" -R a+x \
        "${HOME}/.local/share/kitty-ssh-kitten" \
        || builtin echo -ne '';
      "${chmod_bin}" a+x \
        "${HOME}/.local/share/kitty-ssh-kitten/shell-integration/bash/kitty.bash" \
        || builtin echo -ne '';
    fi
    kitty +kitten ssh -A "${@:1}";
  else
    _SSH_VAR='true' TERM='xterm-256color' "${ssh_bin}" -A "${@:1}";
  fi
  set +x;
  return 0;
}

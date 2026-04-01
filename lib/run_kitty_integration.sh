#!/usr/bin/env bash

# Modify shell to support Kitty functionality

# Kitty terminal replaces the $TERM env var.
#if [[ ! ${TERM} == xterm-kitty ]]; then
# export TERM='xterm-256color';
#fi
# if [[ -z ${KITTY_SHELL_INTEGRATION} ]]; then
#  export KITTY_SHELL_INTEGRATION='enabled';
# fi

# TODO: @luciorq Deprecated and not used anymore. Remove in future versions.

# set right permission for Kitty ssh shell integration files
function __prepare_kitty_shell_integration () {
  \builtin local kitty_inst_path;
  \builtin local kitty_ssh_path;
  \builtin local terminfo_dir;
  \builtin local chmod_bin;
  \builtin local ln_bin;
  \builtin local kitty_bin;
  \builtin local kitty_user_bin;
  \builtin local kitty_link_path;
  if [[ -z ${KITTY_SHELL_INTEGRATION:-} ]]; then
    KITTY_SHELL_INTEGRATION='enabled'
    \builtin export KITTY_SHELL_INTEGRATION;
  fi
  kitty_inst_path="${HOME}/.local/share/kitty-ssh-kitten";
  if [[ -z ${KITTY_INSTALLATION_DIR:-} && -d ${kitty_inst_path} ]]; then
    KITTY_INSTALLATION_DIR="${kitty_inst_path}";
    \builtin export KITTY_INSTALLATION_DIR;
  fi
  if [[ -n ${KITTY_INSTALLATION_DIR:-} ]]; then
    if [[ ${KITTY_INSTALLATION_DIR:-} =~ /Applications/kitty.app ]]; then
      \builtin return 0;
    fi
    KITTY_SHELL_INTEGRATION='enabled';
    \builtin export KITTY_SHELL_INTEGRATION;
    \builtin source "${KITTY_INSTALLATION_DIR:-}/shell-integration/bash/kitty.bash";
  fi
  chmod_bin="$(require 'chmod')";
  if [[ -n ${kitty_inst_path} ]] && [[ -d ${kitty_inst_path} ]]; then
    [[ -d ${kitty_inst_path}/shell-integration ]] \
      && "${chmod_bin}" -R a+x "${kitty_inst_path}/shell-integration";
    [[ -f ${KITTY_INSTALLATION_DIR:-}/shell-integration/bash/kitty.bash ]] \
      && "${chmod_bin}" a+x \
        "${KITTY_INSTALLATION_DIR:-}/shell-integration/bash/kitty.bash";
    [[ -d ${KITTY_INSTALLATION_DIR:-}/terminfo ]] \
      && "${chmod_bin}" -R a+x \
        "${KITTY_INSTALLATION_DIR:-}/terminfo";
    [[ -f ${KITTY_INSTALLATION_DIR:-}/terminfo/kitty.terminfo ]] \
      && "${chmod_bin}" a+x \
        "${KITTY_INSTALLATION_DIR:-}/terminfo/kitty.terminfo";
    [[ -d ${KITTY_INSTALLATION_DIR:-}/terminfo/78/xterm-kitty ]] \
      && "${chmod_bin}" a+x \
        "${KITTY_INSTALLATION_DIR:-}/terminfo/78/xterm-kitty";
  fi
  kitty_ssh_path="${XDG_DATA_HOME:-${HOME}/.local/share}/kitty-ssh-kitten";
  if [[ -d ${kitty_ssh_path} ]]; then
    "${chmod_bin}" -R a+x "${kitty_ssh_path}";
    "${chmod_bin}" a+x "${kitty_ssh_path}/kitty/bin/kitty";
    [[ -f ${kitty_ssh_path}/shell-integration/bash/kitty.bash ]] \
      && "${chmod_bin}" a+x \
        "${kitty_ssh_path}/shell-integration/bash/kitty.bash";
  fi
  terminfo_dir="${TERMINFO:-${HOME}/.terminfo}";
  if [[ -d ${terminfo_dir} ]]; then
    "${chmod_bin}" -R a+x "${terminfo_dir}";
  fi
  if [[ -f ${kitty_inst_path}/shell-integration/bash/kitty.bash ]]; then
    \builtin source "${kitty_inst_path}/shell-integration/bash/kitty.bash";
  fi
  if [[ -f ${KITTY_INSTALLATION_DIR:-}/shell-integration/bash/kitty.bash ]]; then
    \builtin source "${KITTY_INSTALLATION_DIR:-}/shell-integration/bash/kitty.bash";
  fi
  ln_bin="$(which_bin 'ln')";
  kitty_bin="$(which_bin 'kitty')";
  kitty_user_bin="${kitty_inst_path}/kitty/bin/kitty";
  kitty_link_path="${HOME}/.local/bin/kitty";
  if [[ -z ${kitty_bin} ]]; then
    if [[ -f ${kitty_user_bin} ]]; then
      "${chmod_bin}" a+x "${kitty_user_bin}";
      "${ln_bin}" -sf \
        "${kitty_user_bin}" \
        "${kitty_link_path}";
    fi
  fi
  \builtin return 0;
}
# __prepare_kitty_shell_integration;

# if [[ -z ${TERMINFO} && -d ${HOME}/.terminfo ]]; then
#   export TERMINFO="${HOME}/.terminfo";
# fi
# if [[ -f ${HOME}/.terminfo/kitty.terminfo ]]; then
#   export TERM='xterm-kitty';
# fi

# TODO: @luciorq Deprecated and not used anymore. Remove in future versions.
# Kitten Aware SSH connection
function kitty_ssh_fun () {
  \builtin local ssh_bin;
  \builtin local chmod_bin;
  ssh_bin="$(require 'ssh' '-V')";
  chmod_bin="$(require 'chmod')";
  set -x;
  if [[ ${_KITTY_SSH:-} == true ]]; then
    TERM='xterm-256color' "${ssh_bin}" "${@:1}";
  elif [[ ${TERM:-}  == xterm-kitty ]]; then
    if [[ -d ${HOME}/.local/share/kitty-ssh-kitten ]]; then
      "${chmod_bin}" a+x \
        "${HOME}/.local/share/kitty-ssh-kitten/kitty/bin/kitty" \
        || \builtin echo -ne '';
      "${chmod_bin}" -R a+x \
        "${HOME}/.local/share/kitty-ssh-kitten" \
        || \builtin echo -ne '';
      "${chmod_bin}" a+x \
        "${HOME}/.local/share/kitty-ssh-kitten/shell-integration/bash/kitty.bash" \
        || \builtin echo -ne '';
    fi
    kitty +kitten ssh -A "${@:1}";
  else
    _SSH_VAR='true' TERM='xterm-256color' "${ssh_bin}" -A "${@:1}";
  fi
  \builtin set +x;
  \builtin return 0;
}
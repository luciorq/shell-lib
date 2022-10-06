#!/usr/bin/env bash

# Reload interface elements and configurations
function reload_interface () {
  builtin local sys_os;
  sys_os=${OSTYPE}
  if [[ -z ${OSTYPE} ]]; then
    sys_os="$(uname -s)";
  fi
  sys_os="${sys_os,,}";
  if [[ ${sys_os} =~ darwin ]]; then
    __reload_skhd;
    # __reload_karabiner;
    __reload_spacebar;
    __reload_yabai;
  fi
  return 0;
}

# =============================================================================
# MAcOS interface utilitiess
# =============================================================================

# Reload Spacebar - Top Bar replacement
function __reload_spacebar () {
  local user_id;
  user_id=$(id -u);
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.spacebar";
  return 0;
}

# Reload Yabai - Tiling Window manager
function __reload_yabai () {
  local user_id;
  local sudo_bin;
  local yabai_bin;
  user_id=$(id -u);
  sudo_bin="$(require 'sudo')";
  yabai_bin="$(require 'yabai')";
  "${sudo_bin}" "${yabai_bin}" --load-sa;
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.yabai";
  return 0;
}

# Reload SKHD - Keybinding manager
function __reload_skhd () {
  local user_id;
  user_id=$(id -u);
  # skhd --reload;
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.skhd";
  return 0;
}

# Reload Karabiner - Keyboard manager - deprecated
function __reload_karabiner () {
  local user_id;
  user_id=$(id -u);
  launchctl kickstart -k "gui/${user_id}/org.pqrs.karabiner.karabiner_console_user_server";
  return 0;
}

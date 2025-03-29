#!/usr/bin/env bash

# Reload interface elements and configurations
function reload_interface () {
  builtin local sys_os;
  sys_os="${OSTYPE}";
  if [[ -z ${OSTYPE} ]]; then
    sys_os="$(uname -s)";
  fi
  sys_os="${sys_os,,}";
  if [[ ${sys_os} =~ darwin ]]; then
    __reload_skhd;
    # __reload_karabiner;
    # Replaced spacebar with sketchybar
    # + __reload_spacebar;
    __reload_sketchybar;
    __reload_yabai;
  fi
  return 0;
}

# =============================================================================
# MacOS interface utilities
# =============================================================================

# Reload SketchyBar - Top Bar replacement
function __reload_sketchybar () {
  local user_id;
  user_id=$(id -u);
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.sketchybar";
  return 0;
}

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
  # if using HEAD version of yabai
  # + `echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai`
  # + `__reload_yabai_code_signature`
  "${sudo_bin}" "${yabai_bin}" --load-sa;
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.yabai";
  \builtin return 0;
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
  launchctl kickstart \
    -k "gui/${user_id}/org.pqrs.karabiner.karabiner_console_user_server";
  \builtin return 0;
}

# =============================================================================
# Reload signatures
# =============================================================================

# reload yabai signatures after reinstall
function __reload_yabai_code_signature () {
  # check_macos();
  require 'codesign';
  codesign -fs 'yabai-cert' $(which_bin 'yabai');
  \builtin return 0;
}

# reload yabai signatures after reinstall
function __reload_skhd_code_signature () {
  # check_macos();
  require 'codesign';
  codesign -fs 'yabai-cert' $(which_bin 'skhd');
  return 0;
}

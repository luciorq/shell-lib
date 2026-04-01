#!/usr/bin/env bash

# Reload interface elements and configurations
function reload_interface () {
  \builtin local sys_os;
  sys_os="${OSTYPE:-}";
  if [[ -z ${sys_os} ]]; then
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
  \builtin return 0;
}

# =============================================================================
# MacOS interface utilities
# =============================================================================

# Reload SketchyBar - Top Bar replacement
function __reload_sketchybar () {
  \builtin local id_bin;
  \builtin local launchctl_bin;
  \builtin local user_id;
  launchctl_bin="$(require 'launchctl')";
  id_bin="$(require 'id')";
  user_id="$("${id_bin}" -u)";
  "${launchctl_bin}" kickstart -k "gui/${user_id}/homebrew.mxcl.sketchybar";
  \builtin return 0;
}

# Reload Spacebar - Top Bar replacement
function __reload_spacebar () {
  \builtin local id_bin;
  \builtin local user_id;
  \builtin local launchctl_bin;
  id_bin="$(require 'id')";
  launchctl_bin="$(require 'launchctl')";
  user_id="$("${id_bin}" -u)";
  "${launchctl_bin}" kickstart -k "gui/${user_id}/homebrew.mxcl.spacebar";
  \builtin return 0;
}

# Reload Yabai - Tiling Window manager
function __reload_yabai () {
  \builtin local id_bin;
  \builtin local launchctl_bin;
  \builtin local user_id;
  \builtin local sudo_bin;
  \builtin local yabai_bin;
  id_bin="$(require 'id')";
  launchctl_bin="$(require 'launchctl')";
  user_id="$("${id_bin}" -u)";
  sudo_bin="$(require 'sudo')";
  yabai_bin="$(require 'yabai')";

  # if using HEAD version of yabai
  # + `echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai`
  # + `__reload_yabai_code_signature`
  "${sudo_bin}" "${yabai_bin}" --load-sa;
  "${launchctl_bin}" kickstart -k "gui/${user_id}/homebrew.mxcl.yabai";
  \builtin return 0;
}

# Reload SKHD - Keybinding manager
function __reload_skhd () {
  \builtin local id_bin;
  \builtin local launchctl_bin;
  \builtin local user_id;
  id_bin="$(require 'id')";
  launchctl_bin="$(require 'launchctl')";
  user_id="$("${id_bin}" -u)";

  # skhd --reload;
  "${launchctl_bin}" kickstart -k "gui/${user_id}/homebrew.mxcl.skhd";
  \builtin return 0;
}

# Reload Karabiner - Keyboard manager - deprecated
function __reload_karabiner () {
  \builtin local id_bin;
  \builtin local launchctl_bin;
  \builtin local user_id;
  id_bin="$(require 'id')";
  launchctl_bin="$(require 'launchctl')";
  user_id="$("${id_bin}" -u)";
  "${launchctl_bin}" kickstart \
    -k "gui/${user_id}/org.pqrs.karabiner.karabiner_console_user_server";
  \builtin return 0;
}

# =============================================================================
# Reload signatures
# =============================================================================

# reload yabai signatures after reinstall
function __reload_yabai_code_signature () {
  # check_macos();
  \builtin local codesign_bin;
  \builtin local yabai_bin;
  codesign_bin="$(require 'codesign')";
  yabai_bin="$(which_bin 'yabai')";
  "${codesign_bin}" -fs 'yabai-cert' "${yabai_bin}";
  \builtin return 0;
}

# reload yabai signatures after reinstall
function __reload_skhd_code_signature () {
  # check_macos();
  \builtin local codesign_bin;
  \builtin local skhd_bin;
  codesign_bin="$(require 'codesign')";
  skhd_bin="$(which_bin 'skhd')";
  "${codesign_bin}" -fs 'yabai-cert' "${skhd_bin}";
  \builtin return 0;
}

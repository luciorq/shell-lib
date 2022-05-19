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
}

# =============================================================================
# MAcOS interface utilitiess
# =============================================================================

# Reload Spacebar - Top Bar replacement
function __reload_spacebar () {
  local user_id;
  user_id=$(id -u);
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.spacebar";
}
# Reload Yabai - Tiling Window manager
function __reload_yabai () {
  local user_id;
  local sa_exit;
  user_id=$(id -u);
  sa_exit="$(sudo yabai --check-sa; echo $?)";
  if [[ ! ${sa_exit} == 0 ]]; then
    builtin echo -ne "Yabai Scripting Addition needs to be reinstalled.\n";
    sudo yabai --uninstall-sa;
    sudo yabai --install-sa;
    builtin echo -ne "Scripting Addition reinstalled.\n";
  fi
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.yabai";
}

# Reload SKHD - Keybinding manager
function __reload_skhd () {
  local user_id;
  user_id=$(id -u);
  # skhd --reload;
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.skhd";
}
# Reload Karabiner - Keyboard manager - deprecated
function __reload_karabiner () {
  local user_id;
  user_id=$(id -u);
  launchctl kickstart -k "gui/${user_id}/org.pqrs.karabiner.karabiner_console_user_server";
}

#!/usr/bin/env bash


# Reload interface elements and configurations
function reload_interface () {
  builtin local sys_os;
  sys_os="$(uname -s)";
  if [[ ${sys_os} == Darwin ]]; then
    reload_skhd;
    reload_spacebar;
    reload_yabai;
  fi
}

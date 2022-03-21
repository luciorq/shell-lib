#!/usr/bin/env bash

# ==========================================================
# MacOS vars
# TODO luciorq move those to bashrc or custom script called
function __source_mac_vars () {
# + by profile or bashrc
  export PATH="/opt/homebrew/sbin:$PATH"
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
  export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
  export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
  # Bash completion v2 from homebrew
  if [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]]; then
    . "/opt/homebrew/etc/profile.d/bash_completion.sh"
  fi
}

# Add to readline config inputrc
# set page-completions off

# ==========================================================
# Main

function install_macos () {
  builtin local sys_arch;
  builtin local sudo_bin;
  sys_arch="$(uname -m)";
  
  __source_mac_vars;
  __source_dev_deps;

  # Enable Admin rights
  sudo_bin="$(which_bin 'sudo')";
  "${sudo_bin}" echo -ne "Super User\n";

  # __install_macos_devtools;
  # __install_rosetta;
  # __install_homebrew;
  __install_homebrew_pkgs;
  __update_bash_shell;
  __install_fonts;
  __install_kitty;
  # __install_langs;
  # __install_starship;
  __deploy_infrastructure;
  __install_yabai;
  __update_configs;
  __allow_touch_id_sudo;
}

# ==========================================================
# Functions

function __source_dev_deps () {
  local org_name='luciorq';
  local repo_name='shell-lib';
  local shell_lib_path="${_LOCAL_PROJECT:-${HOME}/projects}/${repo_name}";
  local src_fun_arr src_fun src_file_path;
   
  declare declare -a src_fun_arr=(
    force-xdg-basedirs
    which_bin
    check_installed
    is_installed
    source_remote
    mac_install
    mac_update
    config_utils
  )

  for src_fun in ${src_fun_arr[@]}; then
    src_file_path="${shell_lib_path}/${src_fun}.sh"
    if [[ -f ${src_fun_path} ]]; then
      builtin source "${src_fun_path}";
    else
      __source_remote_shell-lib "${src_fun_path}" "${org_name}/${repo_name}";
    fi
  done
}


#!/usr/bin/env bash

# Functions to bootstrap and configure MacOS machines from the command line

# Install Devtools
function __install_macos_devtools () {
  local xcs_bin res_var;
  local sudo_bin mkdir_bin ln_bin;
  xcs_bin="$(which_bin 'xcode-select')";
  sudo_bin="$(which_bin 'sudo')";
  mkdir_bin="$(which_bin 'mkdir')";
  ln_bin="$(which_bin 'ln')";
  res_var=$("${sudo_bin}" "${xcs_bin}" -p 2> /dev/null);
  if [[ ! -n "${res_var}" ]]; then
    "${sudo_bin}" "${xcs_bin}" --install 2> /dev/null;
    sleep 2;
    osascript \
      -e "tell application \"System Events\"" \
        -e "tell process \"Install Command Line Developer Tools\"" \
          -e "keystroke return" \
          -e "click button \"Agree\" of window \"License Agreement\"" \
        -e "end tell" \
      -e "end tell";
    sleep 2;
    "${sudo_bin}" "${xcs_bin}" -p 2> /dev/null;
    while [ $? -ne 0 ]; do
      "${sudo_bin}" "${xcs_bin}" -p 2> /dev/null;
    done
    echo -ne "Devtools installed.\n";
  fi
  if [[ ! -d /usr/local/include ]]; then
    "${sudo_bin}" "${mkdir_bin}" -p /usr/local/include;
  fi

  # Link developer tools headers
  # "${sudo_bin}" "${ln_bin}" -sf \
  #   /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/* \
  #   /usr/local/include 2> /dev/null
  # NOTE: Undo the above
  # for i in $(\ls -A1 /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include); do if [[ -L /usr/local/include/${i} ]]; then sudo unlink /usr/local/include/${i}; fi; done
}


# Install Rosetta2 on ARM
function __install_rosetta () {
  local swu_bin="$(which_bin 'softwareupdate')";
  local sudo_bin="$(which_bin 'sudo')";
  local pgrep_bin="$(which_bin 'pgrep')";
  local lsbom_bin="$(which_bin 'pgrep')";
  local file_res;
  local proc_res;
  local has_rosetta;
  local updater_path bom_path;
  local sys_arch;

  sys_arch="$(uname -m)";

  if [[ ! ${sys_arch} == arm64 ]]; then
   echo -ne "System is not ARM, so not installing Rosetta2.\n";
   return 0;
  fi

  has_rosetta='no';

  if [[ -f /Library/Apple/usr/libexec/oah/libRosettaRuntime && -f /usr/libexec/rosetta/oahd ]]; then
    has_rosetta='yes';
    echo -ne "Rosetta2 files found...\n";
  fi

  proc_res=$("${pgrep_bin}" oahd >/dev/null 2>&1; echo $?)
  if [[ ${proc_res} -eq 0 ]]; then
    has_rosetta='yes';
    echo -ne "Rosetta2 process running...\n";
  fi

  updater_path='/System/Library/CoreServices/Rosetta 2 Updater.app';
  if [[ -d ${updater_path} ]]; then
    open "${updater_path}";
    # TODO luciorq Add Apple Script to click confirm
  fi

  if [[ -f /Library/Apple/System/Library/Receipts/com.apple.pkg.RosettaUpdateAuto.bom ]]; then
    echo -ne "Rosetta2 Updater available...\n";
  fi

  if [[ ${has_rosetta} == no ]]; then
    "${sudo_bin}" "${swu_bin}" --install-rosetta --agree-to-license;
    echo -ne "Rosetta2 installed.\n";
  fi
}

# Install  Homebrew
function __install_homebrew () {
  local brew_bin;
  local curl_bin;
  curl_bin="$(which_bin 'curl')";
  # TODO luciorq Check for non-interactive install instructions
  "$(which_bin 'bash')" -c \
    "$(${curl_bin} -fsSL \
    https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo -ne "Homebrew installed.\n";
  brew_bin="$(which_bin 'brew')";
  "${brew_bin}" doctor;
  "${brew_bin}" analytics off;
  "${brew_bin}" update;
  "${brew_bin}" cleanup;
  "${brew_bin}" analytics off;
  "${brew_bin}" update;
  "${brew_bin}" upgrade;
  "${brew_bin}" install cask;

  # Support for casks upgrade
  "${brew_bin}" tap buo/cask-upgrade;

  # Support for installing fonts
  "${brew_bin}" tap homebrew/cask-fonts;

  "${brew_bin}" reinstall gcc;
}


# Install Homebrew packages
function __install_homebrew_pkgs () {
  local pkg_arr;
  local cask_arr;
  local to_remove_arr;
  local tap_repo_arr;
  local brew_pkg cask_pkg remove_pkg tap_repo;
  local brew_bin;
  local cfg_path;
  cfg_path="$(get_config_path)";
  brew_bin="$(which_bin 'brew')";
  declare -a tap_repo_arr=( $(parse_yaml "${cfg_path}"/vars/homebrew.yaml default homebrew taps) )
  for tap_repo in "${tap_repo_arr[@]}"; do
    "${brew_bin}" tap "${tap_repo}";
  done
   # Remove conflicting packages
  to_remove_arr=( $(parse_yaml "${cfg_path}"/vars/homebrew.yaml default homebrew to_remove) )
  for remove_pkg in ${to_remove_arr[@]}; do
    "${brew_bin}" uninstall --force --ignore-dependencies "${remove_pkg}";
  done
  pkg_arr=( $(parse_yaml "${cfg_path}"/vars/homebrew.yaml default homebrew pkgs) )
  for brew_pkg in ${pkg_arr[@]}; do
    "${brew_bin}" install "${brew_pkg}";
  done
  cask_arr=( $(parse_yaml "${cfg_path}"/vars/homebrew.yaml default homebrew casks) )
  for cask_pkg in ${cask_arr[@]}; do
    "${brew_bin}" install --cask "${cask_pkg}";
  done

  # Install fonts
  __install_fonts;
  # Double check on conflicting packages not being installed
  for remove_pkg in ${to_remove_arr[@]}; do
    "${brew_bin}" uninstall --force --ignore-dependencies "${remove_pkg}";
  done
}

# Set Upgraded BASH as default shell
function __update_bash_shell () {
  local is_bash_allowed;
  local bash_bin;
  bash_bin="$(brew --prefix)/bin/bash";
  is_bash_allowed=$(cat /private/etc/shells | grep "${bash_bin}" || echo -ne '')
  if [[ -z ${is_bash_allowed} ]]; then
    echo "${bash_bin}" | sudo tee -a /private/etc/shells
  fi
  sudo chpass -s "${bash_bin}" "${USER}"
  # TODO luciorq Change the default shell in Terminal App
}

# Install fonts for macOS
function __install_fonts () {
  local brew_bin;
  local fonts_arr font_pkg;
  local cfg_path;
  cfg_path="$(get_config_path)";
  brew_bin="$(which_bin 'brew')";
  "${brew_bin}" tap homebrew/cask-fonts
  declare -a fonts_arr=( $(parse_yaml "${cfg_path}"/vars/homebrew.yaml default homebrew fonts) );
  for font_pkg in ${fonts_arr[@]}; do
    "${brew_bin}" install --cask "${font_pkg}";
  done
}

# Install Kitty terminal
function __install_kitty () {
  local brew_bin;
  local fonts_arr font_pkg;
  brew_bin="$(which_bin 'brew')";
  "${brew_bin}" install --cask kitty;
  # TODO luciorq Make Kitty default terminal
}

# Allow sudo commands to authenticate through TouchID
function __allow_touch_id_sudo () {
  local str_present;
  local pam_sudo_path;
  local wait_var;
  pam_sudo_path='/private/etc/pam.d/sudo'
  replace_str='auth       sufficient     pam_tid.so'
  str_present=$(check_in_file "auth.*sufficient.*pam_tid.so" "${pam_sudo_path}");
  if [[ ${str_present} == false ]]; then

    # Edit /private/etc/pam.d/sudo
    # + Add: 'auth       sufficient     pam_tid.so' to the first line
    # + IMPORTANT It needs to be above the other options!
    # sudo replace_in_file "auth.*sufficient.*pam_tid.so" "${replace_str}" "${pam_sudo_path}";
    builtin echo -ne "Insert the following:\n";
    builtin echo -ne "--> 'auth       sufficient     pam_tid.so'\n";
    builtin echo -ne "To the first line of ${pam_sudo_path}\n";
    builtin echo -ne "Press enter to continue:"
    read wait_var
    sudo visudo "${pam_sudo_path}";
    builtin echo -ne "TouchID sudo enabled.\n";
  else
    builtin echo -ne "TouchID sudo already enabled.\n";
  fi
}

# Open MacOS options menu
function __open_macos_menu () {
  #  Example of opening System Preferencer -> Spotlight -> Search Results
  # + x-help-action://openPrefPane?bundleId=com.apple.preference.spotlight&anchorId=searchResults
  return 0;
}

# Update configuration from applications
function __update_configs () {
  local tldr_bin=$(which_bin 'tldr');
  "${tldr_bin}" --update;
  # TODO luciorq Rebuild configuration files that need template
  # __rebuild_templates;
}

# Install R
function __install_rstats () {
  # from: https://stackoverflow.com/questions/68263165/installing-r-on-osx-big-sur-edit-and-apple-m1-for-use-with-rcpp-and-openmp
  # Also check:
  # + https://johnmuschelli.com/neuroc/installing_devtools/index.html#5_Updating_a_package
  echo -ne "Install R...\n";
}
# Install Python
function __install_python () {
  echo -ne "Install Python...\n";
}


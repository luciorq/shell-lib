#!/usr/bin/env bash

# Install YABAI development version
# + before starting create a self signing certificate
# + following inscrctions from:
# + https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(from-HEAD)#macos-big-sur-and-monterey---automatically-load-scripting-addition-on-startup
function __install_yabai () {
  # Install
  brew install koekeishiya/formulae/yabai --HEAD

  # Key bindings for yabai
  brew install koekeishiya/formulae/skhd --HEAD
  # Change keyboard behavior on mac
  brew install --cask karabiner-elements

  # Spacebar - Menu bar
  brew install cmacrae/formulae/spacebar
  local xav;
  # NOTE luciorq If full functionality is required, please
  # + disable SIP
  builtin echo >&2 -ne "Disable SIP for full funcionality.\nPress Enter to Continue:\n";
  read _xav
  # sudo nvram boot-args=-arm64e_preview_abi

  # Create a self segning certificate
  builtin echo >&2 -ne "Create a Self Signing certificate to continue.\nPress Enter to Continue:";
  read _xav

  
  # TODO luciorq Use check_in_file to test if yabai can be run sudo without password
  local sa_auth_string;
  local sa_auth_present;
  sa_auth_string="${USER} ALL = (root) NOPASSWD: $(brew --prefix)/bin/yabai"
  sa_auth_present=$(check_in_file "${sa_auth_string}" '/private/etc/sudoers.d/yabai')
  if [[ ! -f /private/etc/sudoers.d/yabai ]]; then
    sudo touch /private/etc/sudoers.d/yabai;
    sudo chmod 0440 /private/etc/sudoers.d/yabai;
  fi
  if [[ ${sa_auth_present} == false ]]; then
    echo "${sa_auth_string}" | sudo tee -a /private/etc/sudoers.d/yabai;
  fi

  # Sign, it will prompt to authenticate
  check_installed yabai
  codesign -fs 'yabai-cert' $(which_bin 'yabai')
  codesign -fs 'yabai-cert' $(which_bin 'skhd')
  # copy example config files
  # TODO luciorq Make it xdg base dirs compliant, i.e. add XDG variables
  
  # For Yabai
  [[ ! -d $HOME/.config/yabai ]] && mkdir -p $HOME/.config/yabai;
  if [[ ! -f $HOME/.config/yabai/yabairc ]]; then
    cp /opt/homebrew/opt/yabai/share/yabai/examples/yabairc $HOME/.config/yabai/yabairc;
  fi
  chmod +x ${HOME}/.config/yabai/yabairc;

  # For SKHD
  if [[ ! -d $HOME/.config/skhd ]]; then
    mkdir -p $HOME/.config/skhd;
  fi
  if [[ ! -f $HOME/.config/skhd/skhdrc ]]; then
    cp /opt/homebrew/opt/yabai/share/yabai/examples/skhdrc $HOME/.config/skhd/skhdrc;
  fi
  chmod +x ${HOME}/.config/skhd/skhdrc;

  # For SpaceBar
  if [[ ! -d $HOME/.config/spacebar ]]; then
    mkdir -p $HOME/.config/spacebar;
  fi
  if [[ ! -f $HOME/.config/skhd/spacebar ]]; then
    cp /opt/homebrew/opt/spacebar/share/spacebar/examples/spacebarrc $HOME/.config/spacebar/spacebarrc;
  fi
  chmod +x ${HOME}/.config/spacebar/spacebarrc;

  # Enable accessibility API permission
  # TODO luciorq Add a wait till confirm button and open system preferences

  # start service
  brew services start koekeishiya/formulae/yabai;
  brew services start koekeishiya/formulae/skhd;
  brew services start cmacrae/formulae/spacebar;

  # Disable finder animation that interrupts tiling
  defaults write com.apple.finder DisableAllAnimations -bool true;
  # If this setting needs to be reset, execute:
  # + defaults delete com.apple.finder DisableAllAnimations
}

# Reload Spacebar - Top Bar replacement
function reload_spacebar () {
  local user_id;
  user_id=$(id -u);
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.spacebar";
}
# Reload Yabai - Tiling Window manager
function reload_yabai () {
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
function reload_skhd () {
  local user_id;
  user_id=$(id -u);
  # skhd --reload;
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.skhd";
}
# Reload Karabiner - Keyboard manager - deprecated
function reload_karabiner () {
  local user_id;
  user_id=$(id -u);
  launchctl kickstart -k "gui/${user_id}/org.pqrs.karabiner.karabiner_console_user_server";
}

#!/usr/bin/env bash

# Install YABAI development version
# + before starting create a self signing certificate
# + following inscrctions from:
# + https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(from-HEAD)#macos-big-sur-and-monterey---automatically-load-scripting-addition-on-startup
function _install_yabai () {
  # Install
  brew install koekeishiya/formulae/yabai --HEAD

  # Key bindings for yabai
  brew install koekeishiya/formulae/skhd
  # Change keyboard behavior on mac
  brew install --cask karabiner-elements

  # Spacebar - Menu bar
  brew install cmacrae/formulae/spacebar

  # NOTE luciorq If full functionality is required, please
  # + disable SIP
  builtin echo -ne "\n";


  # Sign, it will prompt to authenticate
  codesign -fs 'yabai-cert' $(which yabai)
  # copy example config files
  # TODO luciorq Make it xdg base dirs compliant, i.e. add XDG variables
  
  # For Yabai
  [[ ! -d $HOME/.config/yabai ]] && mkdir -p $HOME/.config/yabai
  if [[ ! -f $HOME/.config/yabai/yabairc ]]; then
    cp /opt/homebrew/opt/yabai/share/yabai/examples/yabairc $HOME/.config/yabai/yabairc
  fi
  chmod +x ${HOME}/.config/yabai/yabairc

  # For SKHD
  if [[ ! -d $HOME/.config/skhd ]]; then
    mkdir -p $HOME/.config/skhd
  fi
  if [[ ! -f $HOME/.config/skhd/skhdrc ]]; then
    cp /opt/homebrew/opt/yabai/share/yabai/examples/skhdrc $HOME/.config/skhd/skhdrc
  fi
  chmod +x ${HOME}/.config/skhd/skhdrc

  # For SpaceBar
  if [[ ! -d $HOME/.config/spacebar ]]; then
    mkdir -p $HOME/.config/spacebar
  fi
  if [[ ! -f $HOME/.config/skhd/spacebar ]]; then
    cp /opt/homebrew/opt/spacebar/share/spacebar/examples/spacebarrc $HOME/.config/spacebar/spacebarrc
  fi
  chmod +x ${HOME}/.config/spacebar/spacebarrc
 
  

  # Enable accessibility API permission
  # TODO luciorq Add a wait till confirm button and open system preferences


  # start service
  brew services start koekeishiya/formulae/yabai
  brew services start koekeishiya/formulae/skhd
  brew services start cmacrae/formulae/spacebar

  # Disable finder animation that interrupts tiling
  defaults write com.apple.finder DisableAllAnimations -bool true
  # if need to be reset
  # defaults delete com.apple.finder DisableAllAnimations

}

# Reload Yabai and SKHD configurations
function reload_yabai () {
  local user_id;
  user_id=$(id -u);
  sudo yabai --uninstall-sa
  sudo yabai --install-sa

  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.spacebar";
  launchctl kickstart -k "gui/${user_id}/homebrew.mxcl.yabai";
  skhd --reload;
}

function reload_karabiner () {
  local user_id;
  user_id=$(id -u);
 launchctl kickstart -k "gui/${user_id}/org.pqrs.karabiner.karabiner_console_user_server";
}

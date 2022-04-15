#!/usr/bin/env bash

# Install neovim
function __install_neovim () {
  local brew_bin;
  local brew_prefix;

  brew_bin="$(which_bin 'brew')";
  brew_prefix="$("${brew_bin}" --prefix)";
  "${brew_bin}" install neovim --HEAD;

  __install_neovim_configs;
}


# tested on neovim 0.7 alpha
function __install_neovim_configs () {
  brew install npm
  gh repo clone luciorq/neovim-lua ${HOME}/temp/neovim-lua
  # Copy config
  # cp -Rv ${HOME}/temp/neovim-lua/nvim ${HOME}/.config/
  # install packer
  #git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  #  ${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim
  # Install Packages
  # nvim --headless +PackerSync +qa
  sudo npm install -g bash-language-server pyright vscode-langservers-extracted typescript typescript-language-server

}


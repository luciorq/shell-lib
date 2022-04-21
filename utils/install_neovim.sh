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


# Rum Neovim commands from the CLI
# @examples `neovim_command +PlugInstall`
function neovim_command () {
  local nvim_bin;
  local nvim_cmds;
  nvim_bin="$(require 'nvim')";
  "${nvim_bin}" --headless ${nvim_cmds[@]} +qa
}

# tested on neovim 0.7 alpha
function __install_neovim_configs () {
  local npm_bin gh_bin;
  # brew install npm;
  npm_bin="$(require 'npm');"
  gh_bin="$(require 'gh')";

  "${gh_bin}" repo clone \
    luciorq/neovim-lua \
    "${HOME}/workspaces/temp/neovim-lua";

  # Copy config
  # cp -Rv ${HOME}/temp/neovim-lua/nvim ${HOME}/.config/
  # install packer
  #git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  #  ${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim
  # Install Packages
  # sudo
  "${npm_bin}" install -g \
    bash-language-server
    # pyright \
    # vscode-langservers-extracted \
    # typescript \
    # typescript-language-server

  neovim_command +PackerSync
}



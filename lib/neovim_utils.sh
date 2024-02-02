#!/usr/bin/env bash

# Sync Neovim config on a conda environment
function neovim_sync () {
  builtin return 0;
}

# Create Neovim environment in a clean machine
function neovim_install () {
  builtin return 0;
}

# Remove all plugin and cached files
function neovim_clean () {
  rm_safe -rf \
    "${HOME}/.local/state/nvim" \
    "${HOME}/.local/share/nvim" \
    "${HOME}/.cache/nvim";
  builtin return 0;
}

# TODO: @luciorq `neovim` is the wrong conda package name.
# + It is a python library.
# + Apparently there is no `neovim` package in conda-forge.
# Run Neovim
function neovim_run () {
  builtin local env_name;
  env_name='neovim-env';
  conda_create_env "${env_name}" 'neovim' '-c conda-forge';
  conda_run "${env_name}" 'nvim' "${@}";
  builtin return 0;
}

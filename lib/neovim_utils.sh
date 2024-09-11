#!/usr/bin/env bash

# Sync Neovim config on a conda environment
function neovim_sync () {
  builtin return 0;
}

# Create Neovim environment in a clean machine
function neovim_install () {
  builtin local env_name;
  builtin local neovim_bin;
  env_name='neovim-env';
  # neovim_clean;

  if [[ "$(get_os_type)" == "linux" ]]; then
    conda_create_env "${env_name}" \
      "r-base r-tidyverse r-pak r-biocmanager bioconductor-deseq2 bioconductor-edger r-languageserver openssl coreutils nodejs python imagemagick lua luarocks gcc clang llvm radian quarto" \
      "-c bioconda -c conda-forge";
  else
    conda_create_env "${env_name}" \
      "r-base r-tidyverse r-pak r-biocmanager r-languageserver openssl coreutils nodejs python imagemagick lua luarocks clang llvm radian quarto" \
      "-c bioconda -c conda-forge";
  fi
  conda_run "${env_name}" npm install --global --silent bash-language-server;
  conda_run "${env_name}" npm install --global --silent tree-sitter-cli;
  # conda_run "${env_name}" npm install -g dockerfile-language-server-nodejs;

  if [[ -f ${HOME}/.local/share/npm/bin/bash-language-server ]]; then
    conda_run "${env_name}" bash -c 'eval ln -sf "${HOME}/.local/share/npm/bin/bash-language-server" "${CONDA_PREFIX}/bin"';
  fi

  if [[ ! -d "${HOME}/.config/nvim" ]]; then
    conda_run "${env_name}" \
      git clone https://github.com/jmbuhr/quarto-nvim-kickstarter.git \
      "${HOME}/.config/nvim";
  fi

  neovim_bin="$(which_bin nvim)";
  # Create an if statement checking if it is MacOS
  if [[ -z "${neovim_bin}" ]]; then
    if [[ "$(get_os_type)" == "darwin" ]]; then
      require brew;
      brew install neovim;
    elif [[ "$(get_os_type)" == "linux" && "$(get_os_arch)" == "x86_64" ]]; then
      __install_app neovim;
    fi
  fi

  # \builtin local lua_version;
  # lua_version="$(conda_run "${env_name}" lua -v)";
  # lua_version="${lua_version##Lua }";
  # lua_version="${lua_version%% *}";
  # conda_run "${env_name}" luarocks --local --lua-version="${lua_version}" install magick;
  conda_run "${env_name}" luarocks --local --lua-version='5.1' install magick;

  neovim_run --headless -c 'TSUpdate' -qa;

  neovim_run; # "${@}";
  builtin return 0;
}

# Remove all plugin and cached files
function neovim_clean () {
  builtin local env_name;
  env_name='neovim-env';
  rm_safe -rf \
    "${HOME}/.local/state/nvim" \
    "${HOME}/.local/share/nvim" \
    "${HOME}/.cache/nvim" \
    "${HOME}/.config/nvim";

  if [[ -n $(conda_env_exists "${env_name}") ]]; then
    # conda_remove_env neovim-env;
    conda_priv_fun env remove -n "${env_name}" -y -q;
  fi
  \builtin return 0;
}

# TODO: @luciorq `neovim` is the wrong conda package name.
# + It is a python library.
# + Apparently there is no `neovim` package in conda-forge.
# Run Neovim
function neovim_run () {
  builtin local env_name;
  env_name='neovim-env';
  # conda_create_env "${env_name}"; # 'neovim' '-c conda-forge';
  conda_run "${env_name}" 'nvim' "${@}";
  builtin return 0;
}

# alias to neovim run
function neovim_edit () {
  neovim_run -- "${@}";
  builtin return 0;
}

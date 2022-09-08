#!/usr/bin/env bash


# If in doubt check this support page:
# + <https://wiki.archlinux.org/title/XDG_Base_Directory>
# Unfortunately some tools will not use XDG directories unless these are set
#
# - Hex
# - Mix
# - NV
# Main xdg basedirs spec variables
[[ -z ${XDG_CACHE_HOME} ]] && export XDG_CACHE_HOME="${HOME}/.cache";
[[ -z ${XDG_CONFIG_DIRS} ]] && export XDG_CONFIG_DIRS="/etc/xdg";
[[ -z ${XDG_CONFIG_HOME} ]] && export XDG_CONFIG_HOME="${HOME}/.config";
[[ -z ${XDG_DATA_DIRS} ]] && export XDG_DATA_DIRS="/usr/local/share:/usr/share";
[[ -z ${XDG_DATA_HOME} ]] && export XDG_DATA_HOME="${HOME}/.local/share";
[[ -z ${XDG_STATE_HOME} ]] && export XDG_STATE_HOME="${HOME}/.local/state";

# Ack
export ACKRC="${XDG_CONFIG_HOME}/ack/ackrc"

# Atom
export ATOM_HOME="${XDG_DATA_HOME}/atom";

# Visual Studio Code - vscode - Portable
# export VSCODE_PORTABLE="${XDG_DATA_HOME}/vscode"
# if [[ ! -d ${VSCODE_PORTABLE} ]]; then
#  \mkdir -p "${VSCODE_PORTABLE}";
# fi

# AWS CLI
export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME}/aws/credentials";
export AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config";

# Azure CLI
export AZURE_CONFIG_DIR="${XDG_DATA_HOME}/azure";

# Ripgrep
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/config";
if [[ ! -f ${XDG_CONFIG_HOME}/ripgrep/config ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/ripgrep";
  \touch "${XDG_CONFIG_HOME}/ripgrep/config";
fi

# Docker
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker";

# Docker Machine
export MACHINE_STORAGE_PATH="${XDG_DATA_HOME}/docker/machine";

# GnuPG
export GNUPGHOME="${XDG_DATA_HOME}/gnupg";
if [[ ! -d ${XDG_CONFIG_HOME}/gnupg ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/gnupg";
fi
if [[ ! -d ${XDG_DATA_HOME}/gnupg ]]; then
  \mkdir -p "${XDG_DATA_HOME}/gnupg";
  \chmod 0700 "${XDG_DATA_HOME}/gnupg";
fi
if [[ ! -L ${GNUPGHOME}/gpg.conf ]]; then
  \ln -s "${XDG_CONFIG_HOME}/gnupg/gpg.conf" "${GNUPGHOME}/gpg.conf";
fi
if [[ ! -L ${GNUPGHOME}/gpg-agent.conf ]]; then
  \ln -sf \
    "${XDG_CONFIG_HOME}/gnupg/gpg-agent.conf" \
    "${GNUPGHOME}/gpg-agent.conf";
fi

# Less
export LESSKEY="${XDG_CONFIG_HOME}/less/lesskey";
export LESSHISTFILE="${XDG_STATE_HOME}/less/history";

# GNU Screen
export SCREENRC="${XDG_CONFIG_HOME}/screen/screenrc";

# Mozilla Firefox third-party tools
export MOZILLA_CONFIG="${XDG_STATE_HOME}/mozilla";
if [[ ! -d ${XDG_STATE_HOME}/mozilla ]]; then
  \mkdir -p "${XDG_STATE_HOME}/mozilla";
fi

# Mathematica
export MATHEMATICA_USERBASE="${XDG_CONFIG_HOME}/Mathematica";

# Node.js
export NODE_REPL_HISTORY="${XDG_STATE_HOME}/node/repl_history";

# NVM
export NVM_DIR="${XDG_DATA_HOME}/nvm";

# NotMuch
export NOTMUCH_CONFIG="${XDG_CONFIG_HOME}/notmuch/config";

# Parallel
export PARALLEL_HOME="${XDG_CONFIG_HOME}/parallel";

# PostgreSQL
export PSQLRC="${XDG_CONFIG_HOME}/postgres/rc"
export PSQL_HISTORY="${XDG_STATE_HOME}/postgres/history"
export PGPASSFILE="${XDG_CONFIG_HOME}/postgres/pass"
export PGSERVICEFILE="${XDG_CONFIG_HOME}/postgres/service.conf"
# We need to create these directories if not exists
\mkdir -p "${XDG_CONFIG_HOME}/postgres";
\mkdir -p "${XDG_STATE_HOME}/postgres";

# SQLite
export SQLITE_HISTORY="${XDG_DATA_HOME}/sqlite_history"

# Readline
export INPUTRC="${XDG_CONFIG_HOME}/readline/inputrc"

# Vagrant
export VAGRANT_HOME="${XDG_DATA_HOME}/vagrant"
export VAGRANT_ALIAS_FILE="${XDG_DATA_HOME}/vagrant/aliases"

# WeeChat
export WEECHAT_HOME="${XDG_CONFIG_HOME}/weechat"

# wget
if [[ ! -d ${XDG_CONFIG_HOME}/wget ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/wget";
fi
if [[ ! -f ${XDG_CONFIG_HOME}/wget/wgetrc ]]; then
  \touch "${XDG_CONFIG_HOME}/wget/wgetrc";
fi
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc";

if [[ ! -d ${XDG_CACHE_HOME}/wget ]]; then
  \mkdir -p "${XDG_CACHE_HOME}/wget";
fi
builtin alias wget='wget --hsts-file="${XDG_CACHE_HOME}/wget/wget-hsts"';

# =============================================================================
# Programming Languages
# =============================================================================

# JAVA =======================================================================
# java openjdk
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java";
if [[ ! -d "${XDG_CONFIG_HOME}/java" ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/java";
fi
# gradle build tools
export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle";

# Python =====================================================================
# python / jupyter
export IPYTHONDIR="${XDG_CONFIG_HOME}/jupyter";
export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}/jupyter";
export PYLINTHOME="${XDG_CACHE_HOME}/pylint";
export PYTHON_EGG_CACHE="${XDG_CACHE_HOME}/python-eggs";

# Ruby =======================================================================
# Gems - Ruby Gems
export GEM_HOME="${XDG_DATA_HOME}/gem";
export GEM_SPEC_CACHE="${XDG_CACHE_HOME}/gem";
# Bundler - Ruby bundler
export BUNDLE_USER_CONFIG="${XDG_CONFIG_HOME}/bundle";
export BUNDLE_USER_CACHE="${XDG_CACHE_HOME}/bundle";
export BUNDLE_USER_PLUGIN="${XDG_DATA_HOME}/bundle/plugin";

# RUST =======================================================================
# Rustup
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup";

# Cargo - rust cargo
export CARGO_HOME="${XDG_DATA_HOME}/cargo";

# GO =========================================================================
# Golang
export GOPATH="${XDG_DATA_HOME}/go";

# JULIA ======================================================================
# Julia Programming Language
export JULIA_DEPOT_PATH="${XDG_DATA_HOME}/julia:${JULIA_DEPOT_PATH}";

# R ==========================================================================
# Make R language (rstats) respect XDG base dirs spec
export R_ENVIRON_USER="${XDG_CONFIG_HOME}/R/Renviron"
export R_PROFILE_USER="${XDG_CONFIG_HOME}/R/Rprofile"
export R_MAKEVARS_USER="${XDG_CONFIG_HOME}/R/Makevars"
export R_HISTFILE="${XDG_DATA_HOME}/R/Rhistory"
if [[ ! -d "${XDG_DATA_HOME}/R" ]]; then
  \mkdir -p "${XDG_DATA_HOME}/R";
fi
if [[ ! -f ${R_HISTFILE} ]]; then
  \touch "${R_HISTFILE}";
  \chmod 0600 "${R_HISTFILE}";
fi
# Change R package User install path
# + R_LIBS_USER must be version dependent
# export R_LIBS_USER=

# BASH Shell
# GNU BASH history respect XDG base dirs spec
export HISTFILE="${XDG_DATA_HOME}/bash/history";
\mkdir -p "${XDG_STATE_HOME}/bash";
\mkdir -p "${XDG_DATA_HOME}/bash";
if [[ ! -f ${HISTFILE} ]]; then
  \touch "${HISTFILE}";
fi

# =============================================================================
# Android (ADB)
export ADB_VENDOR_KEYS="${XDG_CONFIG_HOME}/adb/adbkey";

# Subversion (svn) - some homebrew formulas used it
\mkdir -p "${XDG_CONFIG_HOME}/subversion";
builtin alias svn='svn --config-dir "${XDG_CONFIG_HOME}/subversion" ';

# TeamSpeak
export TS3_CONFIG_DIR="${XDG_CONFIG_HOME}/ts3client";

# Starship prompt configuration path
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/config.toml";

# LaTeX
\mkdir -p "${XDG_CONFIG_HOME}/latexmk/latexmkrc";
export "TEXMACS_HOME_PATH=${XDG_STATE_HOME}/texmacs";
export "TEXMFHOME=${XDG_DATA_HOME}/texmf";
export "TEXMFVAR=${XDG_CACHE_HOME}/texlive/texmf-var";
export "TEXMFCONFIG=${XDG_CONFIG_HOME}/texlive/texmf-config";

# Lua Rocks
if [[ -d ${HOME}/.luarocks ]]; then
  \rm -rf "${HOME}/.luarocks";
fi
if [[ ! -d ${XDG_CACHE_HOME}/luarocks ]]; then
  \mkdir -p "${XDG_CACHE_HOME}/luarocks";
fi
if [[ ! -d ${XDG_CONFIG_HOME}/luarocks ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/luarocks";
fi
# X11
export XAUTHORITY="${XDG_CONFIG_HOME}/X11/Xauthority";
export XINITRC="${XDG_CONFIG_HOME}/X11/xinitrc";
#NPM
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc";
if [[ ! -d "$(dirname "${NPM_CONFIG_USERCONFIG}")" ]]; then
  \mkdir -p "$(dirname "${NPM_CONFIG_USERCONFIG}")";
fi
if [[ ! -f "${NPM_CONFIG_USERCONFIG}" ]]; then
  \touch "${NPM_CONFIG_USERCONFIG}";
fi
# subversion - svn
builtin alias svn='svn --config-dir "${XDG_CONFIG_HOME}"/subversion';

# Anaconda / Conda / Mamba
export CONDARC="${XDG_CONFIG_HOME}/conda/condarc"
if [[ ! -d "$(dirname "${CONDARC}")" ]]; then
  \mkdir -p "$(dirname "${CONDARC}")";
fi
export CONDA_ENVS_PATH="${XDG_DATA_HOME}/conda/envs";
if [[ ! -d "$(dirname "${CONDA_ENVS_PATH}")" ]]; then
  \mkdir -p "$(dirname "${CONDA_ENVS_PATH}")";
fi
\mkdir -p "$(dirname "${CONDA_ENVS_PATH}")/envs";
\mkdir -p "$(dirname "${CONDA_ENVS_PATH}")/pkgs";
export CONDA_ROOT_PREFIX="${XDG_DATA_HOME}/conda";
export MAMBA_ROOT_PREFIX="${XDG_DATA_HOME}/conda";
export MAMBA_ENVS_PATH="${XDG_DATA_HOME}/conda/envs";

# OpenSSH
# + control masters
if [[ ! -d "${XDG_STATE_HOME}/ssh/cm" ]]; then
  \mkdir -p "${XDG_STATE_HOME}/ssh/cm";
fi

# Dockstore CLI - Partial support, only config file
# + working as version 1.12.2
if [[ ! -d "${XDG_CONFIG_HOME}/dockstore" ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/dockstore";
fi
if [[ ! -f "${XDG_CONFIG_HOME}/dockstore/config" ]]; then
  \touch "${XDG_CONFIG_HOME}/dockstore/config";
fi
builtin alias \
  dockstore='dockstore --script --config "${HOME}/.config/dockstore/config"';

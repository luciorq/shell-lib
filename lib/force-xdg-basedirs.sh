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

# Terminfo - ncurses
\builtin export TERMINFO="${XDG_DATA_HOME}/terminfo";
\builtin export TERMINFO_DIRS="${XDG_DATA_HOME}/terminfo":/usr/share/terminfo;

# Ack
\builtin export ACKRC="${XDG_CONFIG_HOME}/ack/ackrc"

# Atom
\builtin export ATOM_HOME="${XDG_DATA_HOME}/atom";

# Visual Studio Code - vscode - Portable
# export VSCODE_PORTABLE="${XDG_DATA_HOME}/vscode"
# if [[ ! -d ${VSCODE_PORTABLE} ]]; then
#  \mkdir -p "${VSCODE_PORTABLE}";
# fi

# AWS CLI
\builtin export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME}/aws/credentials";
\builtin export AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config";

# Azure CLI
\builtin export AZURE_CONFIG_DIR="${XDG_DATA_HOME}/azure";

# Ripgrep
\builtin export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/config";
if [[ ! -f ${XDG_CONFIG_HOME}/ripgrep/config ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/ripgrep";
  \touch "${XDG_CONFIG_HOME}/ripgrep/config";
fi

# Docker
\builtin export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker";

# Docker Machine
\builtin export MACHINE_STORAGE_PATH="${XDG_DATA_HOME}/docker/machine";

# Minikube
\builtin export MINIKUBE_HOME="${XDG_DATA_HOME}/minikube";

# GnuPG
\builtin export GNUPGHOME="${XDG_DATA_HOME}/gnupg";
if [[ ! -d ${XDG_CONFIG_HOME}/gnupg ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/gnupg";
fi
if [[ ! -d ${XDG_DATA_HOME}/gnupg ]]; then
  \mkdir -p "${XDG_DATA_HOME}/gnupg";
  \chmod 0700 "${XDG_DATA_HOME}/gnupg";
fi
if [[ ! -L ${GNUPGHOME}/gpg.conf \
      && -f ${XDG_CONFIG_HOME}/gnupg/gpg.conf ]]; then
  \ln -sf \
    "../../../.config/gnupg/gpg.conf" \
    "${GNUPGHOME}/gpg.conf";
fi
if [[ ! -L ${GNUPGHOME}/gpg-agent.conf \
      && -f ${XDG_CONFIG_HOME}/gnupg/gpg-agent.conf ]]; then
  \ln -sf \
    "../../../.config/gnupg/gpg-agent.conf" \
    "${GNUPGHOME}/gpg-agent.conf";
fi

# Less
\builtin export LESSKEY="${XDG_CONFIG_HOME}/less/lesskey";
\builtin export LESSHISTFILE="${XDG_STATE_HOME}/less/history";

# GNU Screen
\builtin export SCREENRC="${XDG_CONFIG_HOME}/screen/screenrc";

# Mozilla Firefox third-party tools
\builtin export MOZILLA_CONFIG="${XDG_STATE_HOME}/mozilla";
if [[ ! -d ${XDG_STATE_HOME}/mozilla ]]; then
  \mkdir -p "${XDG_STATE_HOME}/mozilla";
fi

# Mathematica
\builtin export MATHEMATICA_USERBASE="${XDG_CONFIG_HOME}/Mathematica";

# Node.js
\builtin export NODE_REPL_HISTORY="${XDG_STATE_HOME}/node/repl_history";

# NVM
\builtin export NVM_DIR="${XDG_DATA_HOME}/nvm";

# NotMuch
\builtin export NOTMUCH_CONFIG="${XDG_CONFIG_HOME}/notmuch/config";

# Parallel
\builtin export PARALLEL_HOME="${XDG_CONFIG_HOME}/parallel";

# PostgreSQL
\builtin export PSQLRC="${XDG_CONFIG_HOME}/postgres/rc";
\builtin export PSQL_HISTORY="${XDG_STATE_HOME}/postgres/history";
\builtin export PGPASSFILE="${XDG_CONFIG_HOME}/postgres/pass";
\builtin export PGSERVICEFILE="${XDG_CONFIG_HOME}/postgres/service.conf";
# We need to create these directories if not exists
\mkdir -p "${XDG_CONFIG_HOME}/postgres";
\mkdir -p "${XDG_STATE_HOME}/postgres";

# SQLite
\builtin export SQLITE_HISTORY="${XDG_DATA_HOME}/sqlite_history";

# Readline
\builtin export INPUTRC="${XDG_CONFIG_HOME}/readline/inputrc";

# Vagrant
\builtin export VAGRANT_HOME="${XDG_DATA_HOME}/vagrant";
\builtin export VAGRANT_ALIAS_FILE="${XDG_DATA_HOME}/vagrant/aliases";

# WeeChat
\builtin export WEECHAT_HOME="${XDG_CONFIG_HOME}/weechat"

# wget
if [[ ! -d ${XDG_CONFIG_HOME}/wget ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/wget";
fi
if [[ ! -f ${XDG_CONFIG_HOME}/wget/wgetrc ]]; then
  \touch "${XDG_CONFIG_HOME}/wget/wgetrc";
fi
\builtin export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc";

if [[ ! -d ${XDG_CACHE_HOME}/wget ]]; then
  \mkdir -p "${XDG_CACHE_HOME}/wget";
fi
\builtin alias wget='wget --hsts-file="${XDG_CACHE_HOME}/wget/wget-hsts"';

# =============================================================================
# Programming Languages
# =============================================================================

# JAVA =======================================================================
# java openjdk
# NOTE: @luciorq _JAVA_OPTIONS is breaking java inside conda environments.
\builtin export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java";
if [[ ! -d "${XDG_CONFIG_HOME}/java" ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/java";
fi
# gradle build tools
\builtin export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle";

# Python =====================================================================
# python / jupyter
\builtin export IPYTHONDIR="${XDG_CONFIG_HOME}/jupyter";
\builtin export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}/jupyter";
\builtin export PYLINTHOME="${XDG_CACHE_HOME}/pylint";
\builtin export PYTHON_EGG_CACHE="${XDG_CACHE_HOME}/python-eggs";
\builtin export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonrc";
if [[ ! -d "${XDG_CONFIG_HOME}/python" ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/python";
fi

# Streamlit - Python web app framework
\builtin export STREAMLIT_BROWSER_GATHERUSAGESTATS=false

# Ruby =======================================================================
# Gems - Ruby Gems
\builtin export GEM_HOME="${XDG_DATA_HOME}/gem";
\builtin export GEM_SPEC_CACHE="${XDG_CACHE_HOME}/gem";
# Bundler - Ruby bundler
\builtin export BUNDLE_USER_CONFIG="${XDG_CONFIG_HOME}/bundle";
\builtin export BUNDLE_USER_CACHE="${XDG_CACHE_HOME}/bundle";
\builtin export BUNDLE_USER_PLUGIN="${XDG_DATA_HOME}/bundle/plugin";

# RUST =======================================================================
# Rustup
\builtin export RUSTUP_HOME="${XDG_DATA_HOME}/rustup";

# Cargo - rust cargo
\builtin export CARGO_HOME="${XDG_DATA_HOME}/cargo";

# GO =========================================================================
# Golang
\builtin export GOPATH="${XDG_DATA_HOME}/go";

# JULIA ======================================================================
# Julia Programming Language
\builtin export JULIA_DEPOT_PATH="${XDG_DATA_HOME}/julia:${JULIA_DEPOT_PATH}";

# R ==========================================================================
# Make R language (rstats) respect XDG base dirs spec
\builtin export R_ENVIRON_USER="${XDG_CONFIG_HOME}/R/Renviron";
\builtin export R_PROFILE_USER="${XDG_CONFIG_HOME}/R/Rprofile";
\builtin export R_MAKEVARS_USER="${XDG_CONFIG_HOME}/R/Makevars";
\builtin export R_HISTFILE="${XDG_DATA_HOME}/R/Rhistory";
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
\builtin export HISTFILE="${XDG_DATA_HOME}/bash/history";
\mkdir -p "${XDG_STATE_HOME}/bash";
\mkdir -p "${XDG_DATA_HOME}/bash";
if [[ ! -f ${HISTFILE} ]]; then
  \touch "${HISTFILE}";
fi

# Nvidia CUDA
\builtin export CUDA_CACHE_PATH="${XDG_CACHE_HOME}/nv";
if [[ ! -d "${CUDA_CACHE_PATH}" ]]; then
  \mkdir -p "${CUDA_CACHE_PATH}";
fi
# =============================================================================
# Android (ADB)
\builtin export ADB_VENDOR_KEYS="${XDG_CONFIG_HOME}/adb/adbkey";

# Android Studio
\builtin export ANDROID_HOME="${XDG_DATA_HOME}/android";

# Subversion (svn) - some homebrew formulas used it
\mkdir -p "${XDG_CONFIG_HOME}/subversion";
\builtin alias svn='svn --config-dir "${XDG_CONFIG_HOME}/subversion" ';

# TeamSpeak
\builtin export TS3_CONFIG_DIR="${XDG_CONFIG_HOME}/ts3client";

# Starship prompt configuration path
\builtin export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/config.toml";

# LaTeX
\mkdir -p "${XDG_CONFIG_HOME}/latexmk/latexmkrc";
\builtin export "TEXMACS_HOME_PATH=${XDG_STATE_HOME}/texmacs";
\builtin export "TEXMFHOME=${XDG_DATA_HOME}/texmf";
\builtin export "TEXMFVAR=${XDG_CACHE_HOME}/texlive/texmf-var";
\builtin export "TEXMFCONFIG=${XDG_CONFIG_HOME}/texlive/texmf-config";

# Lua Rocks
# if [[ -d ${HOME}/.luarocks ]]; then
#  \rm -rf "${HOME}/.luarocks";
# fi
if [[ ! -d ${XDG_CACHE_HOME}/luarocks ]]; then
  \mkdir -p "${XDG_CACHE_HOME}/luarocks";
fi
if [[ ! -d ${XDG_CONFIG_HOME}/luarocks ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/luarocks";
fi
# X11
\builtin export XAUTHORITY="${XDG_CONFIG_HOME}/X11/Xauthority";
if [[ ! -d ${XDG_CONFIG_HOME}/X11 ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/X11";
fi
if [[ -f ${HOME}/.Xauthority ]]; then
  \cp "${HOME}/.Xauthority" "${XAUTHORITY}";
  \chmod 0600 "${XAUTHORITY}";
fi
\builtin export XINITRC="${XDG_CONFIG_HOME}/X11/xinitrc";
# JavaScript
# NPM
\builtin export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc";
if [[ ! -d "$(dirname "${NPM_CONFIG_USERCONFIG}")" ]]; then
  \mkdir -p "$(dirname "${NPM_CONFIG_USERCONFIG}")";
fi
if [[ ! -f "${NPM_CONFIG_USERCONFIG}" ]]; then
  \touch "${NPM_CONFIG_USERCONFIG}";
fi
# Yarn
\builtin alias yarn='yarn --use-yarnrc "${XDG_CONFIG_HOME}/yarn/config"';
if [[ ! -d "${XDG_CONFIG_HOME}/yarn" ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/yarn";
fi
if [[ ! -f "${XDG_CONFIG_HOME}/yarn/config" ]]; then
  \touch "${XDG_CONFIG_HOME}/yarn/config";
fi

# subversion - svn
\builtin alias svn='svn --config-dir "${XDG_CONFIG_HOME}/subversion"';

# Anaconda / Conda / Mamba
\builtin export CONDARC="${XDG_CONFIG_HOME}/conda/condarc";
if [[ ! -d "$(dirname "${CONDARC}")" ]]; then
  \mkdir -p "$(dirname "${CONDARC}")";
fi
\builtin export CONDA_ENVS_PATH="${XDG_DATA_HOME}/conda/envs";
if [[ ! -d ${CONDA_ENVS_PATH} ]]; then
  \mkdir -p "${CONDA_ENVS_PATH}";
fi
\mkdir -p "$(dirname "${CONDA_ENVS_PATH}")/envs";
\mkdir -p "$(dirname "${CONDA_ENVS_PATH}")/pkgs";
\builtin export CONDA_ROOT_PREFIX="${XDG_DATA_HOME}/conda";
\builtin export MAMBA_ROOT_PREFIX="${XDG_DATA_HOME}/conda";
\builtin export MAMBA_ENVS_PATH="${XDG_DATA_HOME}/conda/envs";

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
\builtin alias \
  dockstore='dockstore --script --config "${HOME}/.config/dockstore/config"';

# Zellij - session manager
\builtin export ZELLIJ_CONFIG_DIR="${XDG_CONFIG_HOME}/zellij";
if [[ ! -d "${ZELLIJ_CONFIG_DIR}" ]]; then
  \mkdir -p "${ZELLIJ_CONFIG_DIR}";
fi

# Google Cloud Platform SDK ---
# + gsutil uses BOTO_CONFIG and
# # [Boto]
# + state_dir = "$XDG_DATA_HOME"/gsutil
# + [GSUtil]
# + state_dir = "$XDG_DATA_HOME"/gsutil
# + state_dir = ~/.local/cache/gsutil
# + needs to be set within BOTO_CONFIG file.
\builtin export BOTO_CONFIG="${XDG_CONFIG_HOME}/gsutil/config";
if [[ ! -d "${XDG_CONFIG_HOME}/gsutil" ]]; then
  \mkdir -p "${XDG_CONFIG_HOME}/gsutil";
fi
if [[ ! -d "${XDG_DATA_HOME}/gsutil" ]]; then
  \mkdir -p "${XDG_DATA_HOME}/gsutil";
fi

# =============================================================================
# Bioinformatics tools ---

# Nextflow - workflow manager
# \builtin export NXF_HOME="${XDG_DATA_HOME}/nextflow";
\builtin export NXF_DISABLE_WAVE_SERVICE=true
\builtin export NXF_DISABLE_CHECK_LATEST=true

# 10X Genomics - Cell Ranger
\builtin export TENX_DISABLE_TELEMETRY=1;

# =============================================================================
# PIXI - conda package manager ---
# Pixi should respect the general DO_NOT_TRACK env var, but it is safe to
# + explicitly disable telemetry via environment variable.
# + Doc: <https://pixi.prefix.dev/latest/reference/telemetry/#how-to-opt-out>
\builtin export DO_NOT_TRACK=1;
\builtin export PIXI_NO_TELEMETRY=1;

# This is probably a wrong one, but worth double checking
# + \builtin export PIXI_DISABLE_TELEMETRY=1;

# =============================================================================
# Homebrew - package manager

# TODO: hallucination nonsense down here, but worth checking if Homebrew
# + respects XDG base directories for cache and config on macOS if a user
# + centric installation would be possible.

# Respect XDG base directories for cache and config
# \builtin export HOMEBREW_CACHE="${XDG_CACHE_HOME}/homebrew";
# \builtin export HOMEBREW_CONFIG="${XDG_CONFIG_HOME}/homebrew";
# if [[ ! -d "${XDG_CACHE_HOME}/homebrew" ]]; then
#   \mkdir -p "${XDG_CACHE_HOME}/homebrew";
# fi
# if [[ ! -d "${XDG_CONFIG_HOME}/homebrew" ]]; then
#   \mkdir -p "${XDG_CONFIG_HOME}/homebrew";
# fi

\builtin export HOMEBREW_NO_ANALYTICS=1;

# =============================================================================

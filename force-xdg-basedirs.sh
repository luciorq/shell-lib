#!/bin/env bash

# Unfortunately some tools will not use XDG directories unless these are set
#
# - Hex
# - Mix
# - NV
[ -z "$XDG_CACHE_HOME" ] && export XDG_CACHE_HOME="$HOME/.cache"
[ -z "$XDG_CONFIG_DIRS" ] && export XDG_CONFIG_DIRS="/etc/xdg"
[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"
[ -z "$XDG_DATA_DIRS" ] && export XDG_DATA_DIRS="/usr/local/share:/usr/share"
[ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME="$HOME/.local/share"
[ -z "$XDG_STATE_HOME" ] && export XDG_STATE_HOME="$HOME/.local/state"

# Ack
export ACKRC="$XDG_CONFIG_HOME/ack/ackrc"

# Atom
export ATOM_HOME="$XDG_DATA_HOME/atom"

# AWS CLI
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials" \
  AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"

# Azure CLI
export AZURE_CONFIG_DIR="$XDG_DATA_HOME/azure"

# Bundler
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle" \
  BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle" \
  BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle/plugin"

# Cargo
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

# Docker Machine
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME/docker/machine"

# GnuPG
export GNUPGHOME="$XDG_DATA_HOME/gnupg"

# Less
export LESSKEY="$XDG_CONFIG_HOME/less/lesskey"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# Mathematica
export MATHEMATICA_USERBASE="$XDG_CONFIG_HOME/Mathematica"

# Node.js
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"

# NotMuch
export NOTMUCH_CONFIG="$XDG_CONFIG_HOME/notmuch/config"

# NVM
export NVM_DIR="$XDG_DATA_HOME/nvm"

# Parallel
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"

# PostgreSQL
export PSQLRC="$XDG_CONFIG_HOME/postgres/rc" \
  PSQL_HISTORY="$XDG_STATE_HOME/postgres/history" \
  PGPASSFILE="$XDG_CONFIG_HOME/postgres/pass" \
  PGSERVICEFILE="$XDG_CONFIG_HOME/postgres/service.conf"
# We need to create these directories if not exists
mkdir -p "$XDG_CONFIG_HOME/postgres" "$XDG_STATE_HOME/postgres"

# Readline
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"

# Rustup
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Vagrant
export VAGRANT_HOME="$XDG_DATA_HOME/vagrant" \
  VAGRANT_ALIAS_FILE="$XDG_DATA_HOME/vagrant/aliases"

# WeeChat
export WEECHAT_HOME="$XDG_CONFIG_HOME/weechat"

#===============================================================
# luciorq extensions START

# wget
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'

# java openjdk
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java

# python / jupyter
export IPYTHONDIR="$XDG_CONFIG_HOME"/jupyter
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter
export PYLINTHOME="$XDG_CACHE_HOME"/pylint
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME"/python-eggs

# Ruby gem
export GEM_HOME="$XDG_DATA_HOME"/gem
export GEM_SPEC_CACHE="$XDG_CACHE_HOME"/gem

# Rust
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup

# Golang
export GOPATH="$XDG_DATA_HOME"/go

# Make R respect XDG base dirs spec
export R_ENVIRON_USER="${XDG_CONFIG_HOME}/R/Renviron"
export R_PROFILE_USER="${XDG_CONFIG_HOME}/R/Rprofile"
export R_HISTFILE="${XDG_DATA_HOME}/R/Rhistory"
# GNU history respect XDG base dirs spec
export HISTFILE="${XDG_DATA_HOME}/bash/history"

# Starship prompt configuration path
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/config.toml"

# luciorq extensions END

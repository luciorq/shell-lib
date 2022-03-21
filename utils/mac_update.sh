#!/usr/bin/env bash

# Functions to update MacOS and related software from the command line

# Update devtools
function __update_macos_devtools () {
  # local xcs_bin="$(which_bin 'xcode-select')";
  local swu_bin="$(which_bin 'softwareupdate')";
  "${swu_bin}" --all --install --force;
  # sudo rm -rf /Library/Developer/CommandLineTools
  # sudo "${xcs_bin}" --install
}

# Update Homebrew
function __update_homebrew () {
  local brew_bin;
  brew_bin="$(which_bin 'brew')";
  "${brew_bin}" update;
  "${brew_bin}" upgrade;
  "${brew_bin}" cleanup;
  "${brew_bin}" analytics off;

  # NOTE Restart services
  # + First time bugged yabai permissions
  # "${brew_bin}" services restart koekeishiya/formulae/yabai
}

# Update all installed casks, even when set to
# + don't be managed by homebrew
function __update_brew_casks () {
  local brew_bin=$(which_bin 'brew');
  "${brew_bin}" cu --all --force --yes;
}

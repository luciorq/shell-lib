#!/usr/bin/env bash

# Update configurations
function sync_config () {
  __sync_config_paths;
}

# Add paths to be synced by dotfiles
function __sync_config_paths () {
  local config_path;
  local config_dir config_dir_arr;
  config_path="${_LOCAL_CONFIG:-$HOME/.config}";

  declare -a config_dir_arr=(
    kitty
    karabiner
    yabai
    skhd
  )
  
  # TODO luciorq check if those directories are in the working tree
  for config_dir in ${config_dir_arr[@]}; do
    config add "${config_path}/${config_dir}";
  done

}

# TODO luciorq Create self deploy tool

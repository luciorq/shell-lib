#!/usr/bin/env bash

# Kitten Aware SSH connection
function ssh_fun () {
  builtin local ssh_bin;
  builtin local _usage;
  _usage="Usage: ${0} <[SSH_ARGS]>";
  builtin unset -v _usage;
  ssh_bin="$(require 'ssh' '-V')";
  builtin set -x;
  "${ssh_bin}" -A -X -Y "${@:1}";
  builtin set +x;
  return 0;
}

# Sync User config over SSH
function __sync_user_config () {
  local _usage;
  _usage="Usage: ${0} [USER@]HOST [PORT] [KEY_PATH]";
  unset -v _usage;
  local ssh_bin;
  local rsync_bin;
  local sync_path_arr;

  local remote_host;
  local host_port;
  local key_path;
  local id_flag;
  remote_host="${1}";
  host_port="${2:-22}";

  if [[ -z ${remote_host} ]]; then
    exit_fun 'No remote host provided.';
    return 1;
  fi
  if [[ -n ${3} ]]; then
    if [[ -f ${HOME}/.ssh/keys/${3} ]]; then
      id_flag=" -i";
      key_path="${HOME}/.ssh/keys/${3}";
    elif [[ -f ${3} ]]; then
      id_flag=" -i";
      key_path="${3}";
    else
      id_flag='';
      key_path='';
    fi
  fi
  ssh_bin="$(require 'ssh' '-V')";
  rsync_bin="$(require 'rsync')";
  if [[ -z ${rsync_bin} ]]; then
    exit_fun "'rsync' is not installed";
    return 1;
  fi
  builtin mapfile -t sync_path_arr < <(
    get_config 'config_sync' 'paths'
  );
  # -o PrintBanner=No
  "${rsync_bin}" \
      -e "ssh -p ${host_port}${id_flag}${key_path} -o LogLevel=error" \
      --delete \
      --relative \
      --recursive \
      -az \
      --exclude '.git' \
      --exclude '.gitignore' \
      --exclude '.gitmodules' \
      --exclude '.gitattributes' \
      --exclude '.gitconfig' \
      --exclude '.github' \
      "${sync_path_arr[@]/#/${HOME}\/.\/}" \
      "${remote_host}":;
  return 0;
}

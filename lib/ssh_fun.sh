#!/usr/bin/env bash

# Kitten Aware SSH connection
function ssh_fun () {
  \builtin local ssh_bin;
  \builtin local _usage;
  _usage="Usage: ${0} <[SSH_ARGS]>";
  \builtin unset -v _usage;
  ssh_bin="$(require 'ssh' '-V')";
  \builtin set -x;
  "${ssh_bin}" -A -X -Y "${@:1}";
  \builtin set +x;
  \builtin return 0;
}

# Sync User config over SSH
function __sync_user_config () {
  \builtin local _usage;
  _usage="Usage: ${0} [USER@]HOST [PORT] [KEY_PATH]";
  \builtin unset -v _usage;
  \builtin local ssh_bin;
  \builtin local rsync_bin;
  \builtin local sync_path_arr;

  \builtin local remote_host;
  \builtin local host_port;
  \builtin local key_path;
  \builtin local key_name;
  \builtin local id_flag;
  remote_host="${1:-}";
  host_port="${2:-22}";
  key_name="${3:-}";
  key_path='';
  id_flag='';
  if [[ -z ${remote_host} ]]; then
    exit_fun 'No remote host provided.';
    \builtin return 1;
  fi
  if [[ -n ${key_name} ]]; then
    if [[ -f ${HOME}/.ssh/keys/${key_name} ]]; then
      id_flag=" -i";
      key_path="${HOME}/.ssh/keys/${key_name}";
    elif [[ -f ${key_name} ]]; then
      id_flag=" -i";
      key_path="${key_name}";
    else
      id_flag='';
      key_path='';
    fi
  fi
  ssh_bin="$(require 'ssh' '-V')";
  rsync_bin="$(require 'rsync')";
  if [[ -z ${rsync_bin} ]]; then
    exit_fun "'rsync' is not installed";
    \builtin return 1;
  fi
  \builtin mapfile -t sync_path_arr < <(
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
  \builtin return 0;
}

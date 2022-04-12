#!/usr/bin/env bash

# SSH Port Forwarding
function ssh_local_port_forwarding () {
  local local_port remote_port;
  local local_ip remote_ip;
  local user;
  local login_port;
  user="${1:-${USER}}";
  local_port='';
  local_ip='';
  remote_port='';
  remote_ip='';
  ssh -N -L \
    ${local_port}:${local_ip}:${remote_port} \
    -p "${login_port}" \
    ${user}@${remote_ip};
}
function ssh_remote_port_forwarding () {
  local local_port remote_port;
  local local_ip remote_ip;
  local user;
  local login_port;
  user="${1:-${USER}}";
  local_port='';
  local_ip='';
  remote_port='';
  remote_ip='';
  ssh -N -R \
    ${local_port}:${local_ip}:${remote_port} \
    -p "${login_port}" \
    ${user}@${remote_ip};
}

# Add key to SSH agent
# + was previously used as alias:
# + alias ssh='eval $(ssh-agent) && ssh-add';
function ssha () {
  local key_name;
  key_name="${1}";
  eval $(ssh-agent) && ssh-add "${key_name}";
}
# Generate SSH key and push to server
function ssh_key_create_and_push () {
  local user="$1";
  local remote_ip="$2";
  local key_name="$3";
  local remote_port="${4:-22}";
  local key_path;
  key_path="${HOME}/.ssh/keys";
  mkdir -p "${key_path}";
  chmod 0700 "${key_path}";
  ssh_generate_key "${user}" "${remote_ip}" "${key_name}";
  ssha "${key_path}/${key_name}";
  ssh_send_key "${user}" "${remote_ip}" "${key_name}" "${remote_port}";
}


# Generate SSH
function ssh_generate_key {
  local _usage="ssh_generate_key <USER> <HOST> <ID_FILE>";
  local ssh_user ssh_host key_name key_type;
  local key_args;
  ssh_user="$1";
  ssh_host="$2";
  key_name="$3";
  key_type="${4:-ed25519}";
  case ${key_type} in
    ed25519)   declare -a key_args=( -t ed25519 -a 200 ) ;;
    rsa)       declare -a key_args=( -t ) ;;
    *) return 1;;
  esac
  ssh-keygen \
    ${key_args[@]} \
    -C "${ssh_user}@${ssh_host}" \
    -f "${HOME}"/.ssh/keys/"${key_name}";
}

# Send SSH Key to remote server
function ssh_send_key {
  local _usage="ssh_send_key <USER> <HOST> <ID_FILE> <HOST_PORT>";
  local ssh_user ssh_host key_name ssh_port;
  ssh_user="$1";
  ssh_host="$2";
  key_name="$3";
  ssh_port="${4:-22}";
  ssh-copy-id \
    -p "${ssh_port}" \
    -i "${HOME}"/.ssh/keys/"${key_name}" \
    "${ssh_user}"@"${ssh_host}";
}


# TODO luciorq Create Rotate keys function, that rotates local and remote keys
# Rotate key and sync with remote
function __ssh_rotate_keys () {
  return 0;
}

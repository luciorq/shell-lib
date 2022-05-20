#!/usr/bin/env bash

# Add key to SSH agent
# + was previously used as alias:
# + alias ssha='eval $(ssh-agent) && ssh-add';
# + Currently being aliased as:
# + alias ssha='ssha_fun'
function ssha_fun () {
  local _usage="usage: ${0} <KEY_FILE_PATH>";
  unset _usage;
  local ssh_agent_bin;
  local ssh_add_bin;
  local ssha_args;
  local key_path;

  key_path="${1}";

  ssh_agent_bin="$(require 'ssh-agent')";
  ssh_add_bin="$(require 'ssh-add')";
  declare -a ssha_args=(
    --apple-use-keychain
  );

  builtin eval "$("${ssh_agent_bin}")" \
    && "${ssh_add_bin}" "${ssha_args[@]}" "${key_path}";
  return 0;
}

# ============================================================================
# SSH Key and certificates
# ============================================================================

# Generate SSH key and push to server
function ssh_key_create_and_push () {
  local _usage="usage: ${0} <USER> <HOST> <ID_FILE> [<PORT>|22]";
  unset _usage;
  local ssh_user;
  local remote_ip;
  local key_name;
  local remote_port;
  local key_dir;
  local mkdir_bin;
  local chmod_bin;
  ssh_user="${1}";
  remote_ip="${2}";
  key_name="${3}";
  remote_port="${4:-22}";
  key_dir="${HOME}/.ssh/keys";
  mkdir_bin="$(require 'mkdir')";
  chmod_bin="$(require 'chmod')"
  if [[ ! -d ${key_dir} ]]; then
    "${mkdir_bin}" -p "${key_dir}";
  fi
  "${chmod_bin}" 0700 "${key_dir}";
  ssh_generate_key "${ssh_user}" "${remote_ip}" "${key_name}";
  ssha_fun "${key_dir}/${key_name}";
  ssh_send_key "${ssh_user}" "${remote_ip}" "${key_name}" "${remote_port}";
  return 0;
}

# Generate SSH
function ssh_generate_key () {
  local _usage="usage: ${0} <USER> <HOST> <ID_FILE>";
  unset _usage;
  local ssh_user;
  local ssh_host;
  local key_name;
  local key_type;
  local key_args;
  local ssh_keygen_bin;
  ssh_user="${1}";
  ssh_host="${2}";
  key_name="${3}";
  key_type="${4:-ed25519}";
  case "${key_type}" in
    ed25519)
      declare -a key_args=(
        -t
        ed25519
        -a
        200
      );
    ;;
    rsa)
      declare -a key_args=(
        -t
      );
    ;;
    *)
      return 1;
    ;;
  esac
  ssh_keygen_bin="$(require 'ssh-keygen')";
  "${ssh_keygen_bin}" \
    "${key_args[@]}" \
    -C "${ssh_user}@${ssh_host}" \
    -f "${HOME}/.ssh/keys/${key_name}";
  return 0;
}

# Send SSH Key to remote server
function ssh_send_key {
  local _usage="usage: ${0} <USER> <HOST> <ID_FILE> <HOST_PORT>";
  unset _usage;
  local ssh_user;
  local ssh_host;
  local key_name;
  local ssh_port;
  local ssh_cp_id_bin;

  ssh_cp_id_bin="$(require 'ssh-copy-id')";
  ssh_user="${1}";
  ssh_host="${2}";
  key_name="${3}";
  ssh_port="${4:-22}";
  "${ssh_cp_id_bin}" \
    -p "${ssh_port}" \
    -i "${HOME}/.ssh/keys/${key_name}" \
    "${ssh_user}@${ssh_host}";
  return 0;
}


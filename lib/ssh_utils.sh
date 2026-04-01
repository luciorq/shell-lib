#!/usr/bin/env bash

# Add key to SSH agent
# + was previously used as alias:
# + alias ssha='eval $(ssh-agent) && ssh-add';
# + Currently being aliased as:
# + alias ssha='ssha_fun'
function ssha_fun () {
  \builtin local _usage;
  _usage="usage: ${0} <KEY_FILE_PATH>";
  \builtin unset _usage;
  \builtin local ssh_agent_bin;
  \builtin local ssh_add_bin;
  \builtin local ssha_args;
  \builtin local key_path;
  \builtin local os_type;

  key_path="${1:-}";
  if [[ -z ${key_path} ]]; then
    exit_fun 'Missing required argument. See usage.';
    \builtin return 1;
  fi

  ssh_agent_bin="$(require 'ssh-agent')";
  ssh_add_bin="$(require 'ssh-add')";
  \builtin declare -a ssha_args;
  ssha_args=();
  os_type="$(get_os_type)";
  if [[ ${os_type} == darwin ]]; then
    \builtin declare -a ssha_args;
    ssha_args=('--apple-use-keychain');
  fi
  \builtin eval "$("${ssh_agent_bin}")" \
    && "${ssh_add_bin}" "${ssha_args[@]}" "${key_path}";
  \builtin return 0;
}

# ============================================================================
# SSH Key and certificates
# ============================================================================

# Generate SSH key and push to server
function ssh_key_create_and_push () {
  \builtin local _usage;
  _usage="usage: ${0} <USER> <HOST> <ID_FILE> [<PORT>|22]";
  \builtin unset _usage;
  \builtin local ssh_user;
  \builtin local remote_ip;
  \builtin local key_name;
  \builtin local remote_port;
  \builtin local key_dir;
  \builtin local mkdir_bin;
  \builtin local chmod_bin;
  ssh_user="${1:-}";
  remote_ip="${2:-}";
  key_name="${3:-}";
  if [[ -z ${ssh_user} || -z ${remote_ip} || -z ${key_name} ]]; then
    exit_fun 'Missing required arguments. See usage.';
    \builtin return 1;
  fi
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
  \builtin return 0;
}

# Generate SSH
function ssh_generate_key () {
  \builtin local _usage;
  _usage="usage: ${0} <USER> <HOST> <ID_FILE>";
  \builtin unset _usage;
  \builtin local ssh_user;
  \builtin local ssh_host;
  \builtin local key_name;
  \builtin local key_type;
  \builtin local key_args;
  \builtin local ssh_keygen_bin;
  ssh_user="${1:-}";
  ssh_host="${2:-}";
  key_name="${3:-}";
  if [[ -z ${ssh_user} || -z ${ssh_host} || -z ${key_name} ]]; then
    exit_fun 'Missing required arguments. See usage.';
    \builtin return 1;
  fi
  key_type="${4:-ed25519}";
  case "${key_type}" in
    ed25519)
      \builtin declare -a key_args;
      key_args=('-t' 'ed25519' '-a' '200');
    ;;
    rsa)
      \builtin declare -a key_args;
      key_args=(-t);
    ;;
    *)
      \builtin return 1;
    ;;
  esac
  ssh_keygen_bin="$(require 'ssh-keygen')";
  "${ssh_keygen_bin}" \
    "${key_args[@]}" \
    -C "${ssh_user}@${ssh_host}" \
    -f "${HOME}/.ssh/keys/${key_name}";
  \builtin return 0;
}

# Send SSH Key to remote server
function ssh_send_key {
  \builtin local _usage;
  _usage="usage: ${0} <USER> <HOST> <ID_FILE> <HOST_PORT>";
  \builtin unset _usage;
  \builtin local ssh_user;
  \builtin local ssh_host;
  \builtin local key_name;
  \builtin local ssh_port;
  \builtin local ssh_cp_id_bin;

  ssh_cp_id_bin="$(require 'ssh-copy-id')";

  ssh_user="${1:-}";
  ssh_host="${2:-}";
  key_name="${3:-}";
  if [[ -z ${ssh_user} || -z ${ssh_host} || -z ${key_name} ]]; then
    exit_fun 'Missing required arguments. See usage.';
    \builtin return 1;
  fi

  ssh_port="${4:-22}";

  "${ssh_cp_id_bin}" \
    -p "${ssh_port}" \
    -i "${HOME}/.ssh/keys/${key_name}" \
    "${ssh_user}@${ssh_host}";
  \builtin return 0;
}


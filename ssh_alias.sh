#!/usr/bin/env bash

function ssh_alias () {
  local host_info_avail;
  local host_name;
  local key_name;
  local key_path;
  local host_port;
  local host_ip;
  local remote_user;
  local key_arg_arr;
  local host_str;
  host_name="${1}";
  host_info_avail="$(get_config --priv host_info "${host_name}")";
  if [[ -z ${host_info_avail} ]]; then
    ssh_fun "${host_name}";
    return 0;
  fi
  key_name="$(get_config --priv host_info "${host_name}" key)";
  if [[ -n ${key_name} ]]; then
    key_path="${HOME}/.ssh/keys/${key_name}";
    declare -a key_arg_arr=(
      -i
      "${key_path}"
    );
  fi
  host_ip="$(get_config --priv host_info "${host_name}" host)";
  if [[ -z ${host_ip} ]]; then
    host_ip="$(get_config --priv host_info "${host_name}" ip)";
    if [[ -z ${host_ip} ]]; then
      host_ip="${host_name}";
    fi
  fi
  host_port="$(get_config --priv host_info "${host_name}" port)";
  if [[ -z ${host_port} ]]; then
    host_port='22';
  fi
  remote_user="$(get_config --priv host_info "${host_name}" user)";
  if [[ -n ${remote_user} ]]; then
    host_str="${remote_user}@${host_ip}";
  else
    host_str="${host_ip}";
  fi
  ssh_fun "${key_arg_arr[@]}" -p "${host_port}" "${host_str}";
  return 0;
}

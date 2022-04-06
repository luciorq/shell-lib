#!/usr/bin/env bash

# SSH Port Forwarding
function ssh_local_port_forwarding () {
  local local_port remote_port;
  local local_ip remote_ip;
  local user;
  user=${USER};
  local_port='';
  local_ip='';
  remote_port='';
  remote_ip='';
  ssh -L ${local_port}:${local_ip}:${remote_port} ${user}@${remote_ip};
}
function ssh_remote_port_forwarding () {
  local local_port remote_port;
  local local_ip remote_ip;
  local user;
  user=${USER};
  local_port='';
  local_ip='';
  remote_port='';
  remote_ip='';
  ssh -R ${local_port}:${local_ip}:${remote_port} ${user}@${remote_ip};
}
# Generate SSH key and push to server
function ssh_key_push () {
  local user;
  local remote_ip;
  local remote_port;
  local path_to_file;
  local comment='';
  sudo mkdir -p "$(dirname ${path_to_file})";
  sudo ssh-keygen -t rsa -b 4096 -f "${path_to_file}" -C "${comment}";
  sudo ssh-copy-id -i "${path_to_file}.pub" -p ${remote_port} ${user}@${remote_ip};
}

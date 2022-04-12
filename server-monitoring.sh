#!/usr/bin/env bash

# Monitoring functions

# Check temperatures for nvidia
function check_temps () {
  servers_exec 'sensors; nvidia-smi -q -d temperature || echo ""'

  # sensors
}

# TODO add check for dir is ZFS and print real(compressed usage)
# + and quota, if available;
# Print Space used at home dir with time of last modification
function check_home_usage () {
  local home_path_arr;
  local user_home;
  if [[ -f /etc/passwd ]]; then
    declare -a home_path_arr=( $(cat /etc/passwd \
      | grep -v "/nologin" \
      | grep -v "/false" \
      | grep -v "/sync" \
      | grep -v "^rstudio-server" \
      | grep -v "^slurm" \
      | grep -v "^_" \
      | grep -v "^#" \
      | cut -d":" -f 6
    ) )
  fi
  for user_home in ${home_path_arr[@]}; do
    sudo du -shL --time "${user_home}";
  done
}

# ======================
# Hardware Inventory functions
function __list_network_devices () {
  sudo lshw -class network -short
}
function __list_manufacturer () {
  dmidecode -s system-manufacturer
}
function __list_storage () {
  ls /dev/disk/by-id | grep -v ".*-part"
}

# ======================
# General overview
function n_threads () {
  cat /proc/cpuinfo | grep processor | wc -l
}


#

#!/usr/bin/env bash

# Monitoring functions

# Check temperatures for nvidia
function check_temps () {
  servers_exec 'sensors; nvidia-smi -q -d temperature || echo ""'

  # sensors
}



# ======================
# Inventory function
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

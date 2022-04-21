#!/usr/bin/env bash

# Disable 'cloud-init' on Ubuntu server
function __remove_cloudinit () {
  local rm_bin;
  rm_bin="$(which_bin 'rm')";
  sudo mkdir -p /etc/cloud;
  sudo touch /etc/cloud/cloud-init.disabled;
  # NOTE luciorq This step needs manual intervention
  sudo dpkg-reconfigure cloud-init;
  sudo apt purge -y cloud-init;
  sudo "${rm_bin}" -rf /etc/cloud/ && sudo rm -rf /var/lib/cloud/
  sleep 3;
  sudo systemctl daemon-reload;
  sleep 3;
  sudo systemctl daemon-reexec;
  # sudo reboot
}

# Enable HWE on Server
function __enable_hwe () {
  sudo apt install --install-recommends -y linux-generic-hwe-20.04-edge;
}


# Convert to Server edition
function __convert_server () {
  sudo apt install ubuntu-server -y;
  sudo systemctl set-default multi-user.target;
  sudo apt purge ubuntu-desktop -y && sudo apt autoremove -y && sudo apt autoclean;
}

# Remove OS Prober, it is only necessary on multi booting systems
# + and throw errors with grub and ZFS
function __remove_osprober () {
  sudo apt purge --yes os-prober;
}

# Clean server
function __clean_server () {
  sudo apt autoremove --purge;
}

# Remove Snaps and Snapd service
function __remove_snapd () {
  local installed_snaps snap_pkg;
  local snap_dir snap_dir_arr;
  declare -a installed_snaps=( $(sudo snap list --all | cut -f1 -d " " | grep -v -i "^Name$") );
  for snap_pkg in ${installed_snaps[@]}; do
    sudo snap remove --purge ${snap_pkg} 2> /dev/null;
  done
  installed_snaps=( $(sudo snap list --all | cut -f1 -d " " | grep -v -i "^Name$") );
  for snap_pkg in ${installed_snaps[@]}; do
    sudo snap remove --purge ${snap_pkg} 2> /dev/null;
  done
  sudo systemctl stop snapd;
  sleep 2;
  sudo systemctl disable snapd;
  sleep 2;
  sudo apt purge --yes snapd;

  systemctl list-units --state failed | grep -oP "snap.*mount" | xargs -n 1 sudo systemctl 2> /dev/null disable;

  declare -a snapd_dir_arr=( /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd /root/snap /snap );
  for snap_dir in ${snap_dir_arr[@]}; do
    if [[ -d "${snap_dir}" ]]; then
      sudo rm -rf "{snap_dir}";
    fi
  done

  # Stop it from being reinstalled by 'mistake' when installing other packages
  sudo mkdir -p /etc/apt/preferences.d/
  sudo touch /etc/apt/preferences.d/no-snap.pref
  builtin echo 'Package: snapd' | sudo tee -a /etc/apt/preferences.d/no-snap.pref
  builtin echo 'Pin: release a=*' | sudo tee -a /etc/apt/preferences.d/no-snap.pref
  builtin echo 'Pin-Priority: -10' | sudo tee -a /etc/apt/preferences.d/no-snap.pref

  # sudo mv no-snap.pref /etc/apt/preferences.d/
  sudo chown root:root /etc/apt/preferences.d/no-snap.pref
}


# Disable NetworkManager and set netplan as default
function __set_netplan_default_network () {
  # Remove renderer: NetworkManager from /etc/netplan/*.yaml
  sudo systemctl stop network-manager.service;
  sudo systemctl disable network-manager.service;
  sudo netplan --debug try;
  sudo netplan generate;
  sudo netplan apply;
}

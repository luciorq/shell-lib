#!/usr/bin/env bash

# Disable 'cloud-init' on Ubuntu server
function __remove_cloudinit () {
  local rm_bin;
  rm_bin="$(which 'rm')";
  sudo touch /etc/cloud/cloud-init.disabled;
  # NOTE luciorq This step needs manual intervention
  sudo dpkg-reconfigure cloud-init;
  sudo apt purge -y cloud-init;
  sudo rm -rf /etc/cloud/ && sudo rm -rf /var/lib/cloud/
  sleep 3;
  sudo systemctl daemon-reload
  sleep 3;
  sudo systemctl daemon-reexec
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

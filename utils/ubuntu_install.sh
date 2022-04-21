#!/usr/bin/env bash

# Functions to bootstrap and configure Ubuntu machines from the command line

# =============================================================================
# Desktop Install
# =============================================================================
function __install_ubuntu_desktop () {
  __install_nala;
}

# =============================================================================
# Server Install
# =============================================================================
function __install_ubuntu_server () {
  __install_nala;
  __convert_server;
  __enable_hwe;
  __remove_desktop_resources;
  __remove_network_manager;
  __remove_cloudinit;
  __remove_snapd;
  __remove_unwanted_resources;
  __set_netplan_default_network;
  __allow_nvidia_headless;
  __clean_server;
}

# =============================================================================
# Utilities
# =============================================================================

# Install NALA Apt wrapper
# + from: https://gitlab.com/volian/nala
function __install_nala () {
  local gdebi_bin;
  local sys_arch arch_str;
  local get_url base_url;
  local version_str;
  local dl_path;
  local deb_name;
  gdebi_bin="$(require 'gdebi')";
  rm_bin="$(which_bin 'rm')";
  sys_arch="$(uname -m)";
  case ${sys_arch} in
    x86_64)    arch_str='amd64'    ;;
    aarch64)   arch_str='arm64'    ;;
    arm64)     arch_str='arm64'    ;;
    *) builtin echo -ne ")Architecture not supported.\n"; return 1;;
  esac

  # Check latest version at:
  # + amd64: https://deb.volian.org/volian/dists/scar/main/binary-amd64/Packages
  # + arm64: https://deb.volian.org/volian/dists/scar/main/binary-arm64/Packages
  # Example URL:
  # + https://deb.volian.org/volian/pool/main/n/nala/nala_0.7.2-0volian1_amd64.deb
  version_str='0.7.2-0volian1';
  base_url="https://deb.volian.org/volian";
  deb_name="nala_${version_str}_${arch_str}.deb";
  get_url="${base_url}/pool/main/n/nala/${deb_name}";
  dl_path="$(create_temp 'nala')";
  download "${get_url}" "${dl_path}";
  sudo "${gdebi_bin}" -n "${dl_path}/${deb_name}";
  "${rm_bin}" "${dl_path}/${deb_name}";
  sudo nala fetch;
}

# Remove desktop based Packages
function __remove_desktop_resources () {
  sudo apt purge --auto-remove 'ubuntu-desktop'
  sudo apt purge --auto-remove 'gnome'
  sudo apt purge --auto-remove 'pulseaudio'
  sudo apt purge --auto-remove gnome-*
  # Remove all flavors of ubuntu desktop
  sudo apt purge --auto-remove 'buntu-desktop$'
  sudo apt purge --auto-remove 'mate-desktop'
  # Agressively removes all packages for desktop
  # + sudo apt purge --auto-remove '\-desktop$'
}

# Remove NetworkManager and set default to netplan
function __remove_network_manager () {
  local services_arr _service;
  local pkg_arr _pkg;
   declare -a services_arr=(
    NetworkManager.service
    NetworkManager-wait-online.service
    NetworkManager-dispatcher.service
    network-manager.service

  )
  declare -a pkg_arr=(
    network-manager
  )
  for _service in ${services_arr[@]}; do
    sudo systemctl stop ${_service};
    sudo systemctl disable ${_service};
  done
  for _pkg in ${pkg_arr[@]}; do
    sudo apt purge --yes --auto-remove ${_pkg}
  done
  sudo apt purge --auto-remove network-manage*
  # sudo apt purge --auto-remove gnome-*

  sudo systemctl stop network-manager.service
  sudo systemctl disable network-manager.service
}


# Remove some not used service and Packages
function __remove_unwanted_resources () {
  local pkg_arr;
  local _pkg;
  local services_arr;
  local _service;
  declare -a services_arr=(
    mongodb.service
    GeoMxNGSPipeline.service
  )
  declare -a pkg_arr=(
    mongodb
    rstudio
  )
  for _service in ${services_arr[@]}; do
    sudo systemctl stop ${_service};
    sudo systemctl disable ${_service};
  done
  for _pkg in ${pkg_arr[@]}; do
    sudo apt purge --yes --auto-remove ${_pkg}
  done

}

# Deny open-source nvidia drivers from kernel
function __allow_nvidia_headless () {
  sudo bash -c \
    "echo blacklist nouveau > /etc/modprobe.d/deny-nvidia-nouveau.conf"
  sudo bash -c \
    "echo options nouveau modeset=0 >> /etc/modprobe.d/deny-nvidia-nouveau.conf"
  cat '/etc/modprobe.d/deny-nvidia-nouveau.conf';
  sudo update-initramfs -u;
}

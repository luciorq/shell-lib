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
}

# =============================================================================
#
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
    *) builtin echo -ne ")Arcitecture not supported.\n"; return 1;;
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


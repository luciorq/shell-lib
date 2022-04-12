#!/usr/bin/env bash

# Install and Update Packages from default Ubuntu repositories
function __update_apt_pkgs () {
  local nala_bin;
  local sudo_bin;
  local config_path;
  local apt_pkgs_arr;
  config_path="$(get_config_path)";
  declare -a apt_pkgs_arr=( $(parse_yaml "${cfg_path}"/vars/apt_pkgs.yaml default apt) );
  nala_bin="$(which_bin 'nala')";
  sudo_bin="$(which_bin 'sudo')";
  if [[ -n ${nala_bin} ]]; then
    "${sudo_bin}" "${nala_bin}" fetch -y;
    "${sudo_bin}" "${nala_bin}" update -y;
    "${sudo_bin}" "${nala_bin}" upgrade -y;
    "${sudo_bin}" "${nala_bin}" install -y ${apt_pkgs[@]};
  else
    "${sudo_bin}" apt update -y;
    "${sudo_bin}" apt upgrade -y;
    "${sudo_bin}" apt install -y ${apt_pkgs[@]};
  fi
  "${sudo_bin}" apt dist-upgrade --dry-run -q;
  return 0;
}

# Install and Update Snap packages
function __update_snap_pkgs () {
  local snap_bin;
  snap_bin="$(which_bin 'snap')";
  if [[ -n ${snap_bin} ]]; then
    sudo snap refresh --list;
    sudo snap refresh;
    # remove older snaps
    snap list --all \
      | awk '/disabled/{print $1, $3}' \
      | while read snap_app_name snap_revision; \
      do "$(which_bin sudo)" snap remove "${snap_app_name}" \
        --revision="${snap_revision}"; \
      done
  else
    builtin echo -ne "--> Snapcraft is not available in the machine...\n";
  fi
  return 0;
}

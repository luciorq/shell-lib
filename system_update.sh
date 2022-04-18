#!/usr/bin/env bash

# TODO luciorq Remove variables outside of functions
declare -r _SHELL_LIB_PROJECT="luciorq/shell-lib"
declare -r _SHELL_LIB_VERSION="latest"
declare _REPO_VERSION

if [[ "${_SHELL_LIB_VERSION}" == "latest" ]]; then
  _REPO_VERSION="main";
else
  _REPO_VERSION="${_SHELL_LIB_VERSION}";
fi


# Update programming languages
function _update_programming_languages () {
  local script_url
  # local app_version
  # app_version="$1";
  script_url="https://raw.githubusercontent.com/${_SHELL_LIB_PROJECT}";
  script_url="${script_url}/${_REPO_VERSION}/install_lang.sh";
  source_remote "${script_url}";
  # TODO luciorq Replace install paths to install on /opt/langs
  # + and link to /usr/local/bin
  install_lang R 4.1.2 '${HOME}/.local/apps' link=true;
  install_lang python 3.10.2 '${HOME}/.local/apps' link=true;
}



# --------------------------------------------------------------------------

# Main system update function
function system_update () {
  local sys_info;
  declare -A sys_info;
  _parse_system_info sys_info;
  sys_os_name="";
  if [[ "${sys_info["os_name"]}" == Ubuntu ]]; then
    _system_update_ubuntu;
  elif [[ "${sys_info["os_name"]}" == macOS ]]; then
    _system_update_macos;
  else
    builtin echo >&2 -ne "No supported system detected.\n";
    return 1;
  fi

  # Update applications configurations
  echo -ne "\n\nUpdating Applications Configurations\n\n";
  local tldr_bin="$(which_bin 'tldr')";
  if [[ -n ${tldr_bin} ]]; then
    "${tldr_bin}" --update;
  fi
  local bat_bin="$(which_bin 'bat')";
  if [[ -n ${bat_bin} ]]; then
    "${bat_bin}" cache --build;
  fi


  echo -ne "\n\nSystem update succesfull.\n\n";
}

# Parse system info into array
function _parse_system_info () {
  local _key sys_info_arr;
  local sys_arr;
  declare -n sys_info_arr="$1";
  declare -a sys_arr=($(_get_system_info));
  sys_info_arr["os_name"]="${sys_arr[0]}";
  sys_info_arr["os_version"]="${sys_arr[1]}";
  sys_info_arr["arch"]="${sys_arr[2]}";
  sys_info_arr["kernel_name"]="${sys_arr[3]}";
  sys_info_arr["kernel_version"]="${sys_arr[4]}";
  for _key in "${!sys_info_arr[@]}"; do
    sys_info_arr[${_key}]=$(
      echo -ne "${sys_info_arr[${_key}]}"| sed -e "s/^'//g" | sed -e "s/'$//g";
    );
  done
}

# Get system description strings
function _get_system_info () {
  local sys_arch sys_kernel_name sys_kernel_version;
  local sys_os_name sys_os_version sys_strings_arr;
  sys_arch="$(uname -m)";
  sys_kernel_name="$(uname -s)";
  sys_kernel_version="$(uname -r)";
  if [[ "${sys_kernel_name}" == Linux ]]; then
    sys_os_name="$(grep -i '^name=' /etc/os-release | sed -e 's/\"//g' | sed -e 's/name=//gi')";
    sys_os_version="$(grep -i '^version_id=' /etc/os-release | sed -e 's/\"//g' | sed -e 's/version_id=//gi')";
  elif [[ "${sys_kernel_name}" == Darwin ]]; then
    sys_os_name="$(sw_vers -productVersion)";
    sys_os_version="$(sw_vers -productName)";
  fi
  echo -ne "'${sys_os_name}' '${sys_os_version}' ${sys_arch}' '${sys_kernel_name}' '${sys_kernel_version}'";
  return 0;
}


# MacOS specific updates
function _system_update_macos () {
  return 0;
}

# Ubuntu specific updates
function _system_update_ubuntu () {
  local snap_app_name snap_revision;

  if [[ "$(sudo_check)" == false ]]; then
    builtin echo >&2 -ne "Insuficient permissions.\n";
    return 1;
  fi

  echo -ne "\n\nUpdating packages from package manager (APT) ...\n\n";
  __update_apt_pkgs;

  echo -ne "\n\nUpdating applications via Snap (Snapcraft) ...\n\n";
  __update_snap_pkgs;

  echo -ne "\n\nUpdating Firmwares and Drivers (fwupdmgr) ...\n\n";
  sudo fwupdmgr refresh --force;
  sudo fwupdmgr get-upgrades;
  # --offline
  sudo fwupdmgr update -y \
      --ignore-power \
      --no-reboot-check;

  # TODO luciorq Add python, golang, rust, and R packages to auto update
  echo -ne "\n\nUpdating Programming Languages (R, Python, Node.js & Go)\n\n";
  # _update_programming_languages;

  # TODO luciorq Use install_app module to install system applications
  # + using ansible need to integrate installed module to
  # + "configured module paths" or add new module paths to
  # + the "ansible_cfg_path" file.

  echo -ne "\n\nUpdating Custom Applications (install_apps)\n\n";

  local ansible_bin;
  local ansible_cfg_path;
  local ansible_playbook_path;

  ansible_bin="$(require 'ansible-playbook')";
  ansible_cfg_path="${_BCA_CONFIG}";
  ansible_playbook_name=test_install_app.yaml;
  ansible_playbook_path="${_LOCAL_PROJECT}"/villabioinfo/install_apps/playbooks;
  ansible_playbook_path="${ansible_playbook_path}/${ansible_playbook_name}";

  if [[ -n ${ansible_bin} ]]; then
    ANSIBLE_CONFIG="${ansible_cfg_path}" "${ansible_bin}" \
      "${ansible_playbook_path}" \
      --extra-vars "@${_ANS_SEV}";
  else
    echo -ne "\n\nAnsible not set correctly.\n\n";
  fi
  # ANSIBLE_CONFIG=${ansible_cfg_path} ansible \
  #   -v ${host_exec} -m "${module_name}" -a "${cmd_exec}"


}


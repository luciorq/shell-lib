#!/bin/env bash

declare -r _SHELL_LIB_PROJECT="luciorq/shell-lib"
declare -r _SHELL_LIB_VERSION="latest"
declare _REPO_VERSION

if [[ "${_SHELL_LIB_VERSION}" == "latest" ]]; then
  _REPO_VERSION="main";
else
  _REPO_VERSION="${_SHELL_LIB_VERSION}";
fi

function update_programming_languages () {
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



# System update functions
function system_update () {
  local snap_app_name snap_revision;
  local ansible_cfg_path;
  
  if [[ "$(sudo_check)" == false ]]; then
    echo -ne "Insuficient permissions.\n";
    return 1;
  fi

  echo -ne "\n\nUpdating packages from package manager (APT) ...\n\n"
  sudo apt update -y -q
  sudo apt upgrade -y -q
  sudo apt dist-upgrade --dry-run -q

  echo -ne  "\n\nUpdating applications via Snap (Snapcraft) ...\n\n"
  sudo snap refresh --list
  sudo snap refresh
  # remove older snaps
  snap list --all \
    | awk '/disabled/{print $1, $3}' \
    | while read snap_app_name snap_revision; \
    do "$(which_bin sudo)" snap remove "${snap_app_name}" \
      --revision="${snap_revision}"; \
    done
  
  echo -ne "\n\nUpdating Firmwares and Drivers (fwupdmgr) ...\n\n"
  sudo fwupdmgr refresh --force
  sudo fwupdmgr get-upgrades
  # --offline
  sudo fwupdmgr update -y \
      --ignore-power \
      --no-reboot-check

  # TODO luciorq Add python, golang, rust, and R packages to auto update
  echo -ne "\n\nUpdating Programming Languages (R, Python, Node.js & Go)\n\n"
  # update_programming_languages; 
  
  # TODO luciorq Use install_app module to install system applications 
  # + using ansible need to integrate installed module to
  # + "configured module paths" or add new module paths to
  # + the "ansible_cfg_path" file.

  echo -ne  "\n\nUpdating Custom Applications (install_apps)\n\n"

  ansible_cfg_path="${_BCA_CONFIG}";
  # TODO luciorq Change playbook path to be dependaple on variable;
  # + e.g. ${_LOCAL_PROJECT}
  local pb_path
  pb_path="${_LOCAL_PROJECT}"/villabioinfo/install_apps/playbooks
  ansible-playbook \
    "${pb_path}"/test_install_app.yaml \
    --extra-vars "@${_LOCAL_CONFIG}/ansible/inventories/vars/cat.yml"

  # ANSIBLE_CONFIG=${ansible_cfg_path} ansible \
  #   -v ${host_exec} -m "${module_name}" -a "${cmd_exec}"
  # Update applications configurations
  echo -ne "\n\nUpdating Applications Configurations\n\n";
  tldr --update;
}


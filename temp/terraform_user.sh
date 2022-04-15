#!/usr/bin/env bash

function __terraform_bootstrap () {
  local bottle_pkgs;
  local _pkg;
  local bca_prefix;
  bca_prefix="${HOME}/.local/opt/apps";
  declare -a bottle_pkgs=(
    git
    gettext
    pcre2
  )
  for _pkg in ${bottle_pkgs[@]}; do
    __brew_download_bottle "${_pkg}";
  done
  __install_patch_elf;
  # patchelf_bin="${bca_prefix}/tools/patchelf/bin/patchelf";
  # git_bin="${bca_prefix}/bottles/git/2.35.1/bin/git";
  mkdir -p ${HOME}/.local/bin;
  for _pkg in ${bottle_pkgs[@]}; do
    __fix_rpaths "${_pkg}";
  done

}

# =================================================================
# Utils

function __fix_rpaths () {
  echo 'true';
  return 0;
}

function __brew_download_bottle () {
  local pkg_name;
  local pkg_url;
  local bottle_json;
  local bottle_response;
  local sys_kernel;
  local sys_arch;
  local sys_version;
  local bottle_type;
  local install_path;
  pkg_name="$1";
  install_path="$(__install_path)";
  bottle_response=$(curl -f -s -S -o /dev/null -L -I -w "%{http_code}" -X GET https://formulae.brew.sh/api/bottle/${pkg_name}.json);
  if [[ ${bottle_response} == 200 ]]; then
    bottle_json=$(curl -f -S -s -L -X GET "https://formulae.brew.sh/api/bottle/${pkg_name}.json" 2> /dev/null || builtin -ne echo '');
  else
    builtin echo >&2 "Bottle not available for '${pkg_name}'\n";
    return 1;
  fi
  sys_kernel="$(uname -s | tr '[:upper:]' '[:lower:]')";
  sys_arch="$(uname -m | tr '[:upper:]' '[:lower:]')";
  if [[ ${sys_kernel} == darwin ]]; then
    sys_version="$(sw_vers -ProductVersion)";
  else
    sys_version='linux';
  fi
  case "${sys_arch}_${sys_version}" in
    x86_64_11*)        bottle_type='big_sur'          ;;
    x86_64_12*)        bottle_type='monterey'         ;;
    arm64_11*)         bottle_type='arm64_big_sur'    ;;
    arm64_12*)         bottle_type='arm64_monterey'   ;;
    x86_64_linux)      bottle_type='x86_64_linux'     ;;
    *)
      builtin echo >&2 "Bottle not available for '${pkg_name}' in ${sys_arch}_${sys_kernel}\n";
      return 1;
    ;;
  esac
  pkg_url=$(echo $bottle_json | sed "s|.*\(${bottle_type}.*${pkg_name}/blobs/sha256:[a-f0-9]*\).*|\1|" | sed "s|.*\"url\":\"||");
  base_path="${install_path}/bottles";
  mkdir -p "${base_path}";
  curl -s -S -f -L -H "Authorization: Bearer QQ==" -o "${base_path}/${pkg_name}.tar.gz" "${pkg_url}";
  tar -C "${base_path}" -xzf "${base_path}/${pkg_name}.tar.gz";
  rm "${base_path}/${pkg_name}.tar.gz";
}

function __install_path () {
  local base_path;
  base_path="${HOME}/.local/opt";
  builtin echo -ne "${base_path}";
  return 0;
}

function __get_gh_latest_release () {
  local repo;
  local release_url;
  local latest_version;
  repo="$1";
  release_url=$(curl -fsSL -I -o /dev/null -w %{url_effective} "https://github.com/${repo}/releases/latest");
  latest_version=$(echo "${release_url}" | sed "s|.*/tag/||");
  builtin echo -ne "${latest_version}";
  return 0;
}

function __install_patch_elf () {
  local install_path;
  local release_version;
  local sys_arch;
  local download_url;
  local pkg_name;
  pkg_name='patchelf';
  sys_arch="$(uname -m)";
  install_path="$(__install_path)/${pkg_name}";
  release_version="$(__get_gh_latest_release 'NixOS/patchelf')";
  download_url="https://github.com/NixOS/patchelf/releases/download/${release_version}/patchelf-${release_version}-${sys_arch}.tar.gz";
  mkdir -p "${install_path}";
  curl -fsSL -o "${install_path}/${pkg_name}.tar.gz" "${download_url}";
  tar -C "${install_path}" -xzf "${install_path}/${pkg_name}.tar.gz";
  rm "${install_path}/${pkg_name}.tar.gz";
}

#!/usr/bin/env bash

# Main function to install tools and
# + reload user environment
function bootstrap_user () {
  local install_type;
  install_type='--user';
  mkdir -p "${HOME}/projects";
  mkdir -p "${HOME}/workspaces";
  mkdir -p "${HOME}/.local/bin";
  mkdir -p "${HOME}/.local/lib";
  mkdir -p "${HOME}/.local/opt/apps";
  # __check_glibc "${install_type}";
  __build_git "${install_type}";
  __install_yq;
  __build_bash "${install_type}";
  install_apps "${install_type}";
  __install_python_cli_tools;
  source_configs;
  __clean_home;
  return 0;
}

function __clean_home () {
  local remove_dirs _dir;
  local rm_bin;
  rm_bin="$(which_bin 'rm')";
  declare -a remove_dirs=(
    .vim
    .vimrc
    .npm
    .gem
    .sudo_as_admin_successful
  )
  for _dir in "${remove_dirs[@]}"; do
    if [[ -f ${HOME}/${_dir} ]]; then
      "${rm_bin}" "${HOME}/${_dir}";
    elif [[ -d ${HOME}/${_dir} ]]; then
      "${rm_bin}" -rf "${HOME}/${_dir}";
    fi
  done;
  return 0;
}

# =============================================================================
# Build Tools from source
# =============================================================================
function __build_git () {
  local build_path;
  local inst_path;
  local num_threads;
  local get_url;
  local rm_bin make_bin;
  rm_bin="$(which_bin 'rm')";
  make_bin="$(which_bin 'gmake')";
  if [[ -z ${make_bin} ]]; then
    make_bin="$(require 'make')";
  fi
  # inst_path="$(__install_path --user)";
  inst_path="${HOME}/.local";
  if [[ -f ${inst_path}/bin/git ]]; then
    return 0;
  fi
  num_threads=$(nproc);
  if [[ ${num_threads} -gt 8 ]]; then
    num_threads=8;
  fi
  get_url='https://github.com/git/git/archive/refs/heads/main.zip';
  build_path="$(create_temp git-inst)";
  download "${get_url}" "${build_path}";
  unpack "${build_path}/main.zip" "${build_path}";
  make -C "${build_path}/git-main" configure -j ${num_threads};
  (cd "${build_path}/git-main" && ./configure --prefix="${inst_path}");
  make -C "${build_path}/git-main" -j ${num_threads};
  make -C "${build_path}/git-main" install -j ${num_threads};
  "${rm_bin}" -rf "${build_path}/git-main" "${build_path}/main.zip";
  "${rm_bin}" -rf "${build_path}";
  "${inst_path}/bin/git" --version;
}

function __build_bash () {
  local latest_tag;
  local mirror_repo;
  local build_version;
  local build_path;
  local inst_path;
  local num_threads;
  local get_url;
  local rm_bin make_bin;
  rm_bin="$(which_bin 'rm')";
  make_bin="$(which_bin 'gmake')";
  if [[ -z ${make_bin} ]]; then
    make_bin="$(require 'make')";
  fi
  mirror_repo='bminor/bash'
  latest_tag=$(curl -fsSL "https://api.github.com/repos/${mirror_repo}/tags");
  builtin mapfile -t latest_tag < <(
    builtin echo -ne "${latest_tag}" \
      | grep '"name": ' \
      | grep -v "\-rc\|\-beta\|\-alpha\|devel"
  )
  # build_version="5.1";
  build_version=$(
    builtin echo -ne "${latest_tag[1]}" \
      | sed 's|\"bash\-\(.*\)",|\1|g'
  )
  # inst_path="$(__install_path --user)";
  inst_path="${HOME}/.local";
  if [[ -f ${inst_path}/bin/bash ]]; then
    return 0;
  fi
  num_threads=$(nproc);
  if [[ ${num_threads} -gt 8 ]]; then
    num_threads=8;
  fi
  get_url="https://ftp.gnu.org/gnu/bash/bash-${build_version}.tar.gz";
  build_path="$(create_temp bash-inst)";
  download "${get_url}" "${build_path}";
  unpack "${build_path}/bash-${build_version}.tar.gz" "${build_path}";
  # make -C "${build_path}/bash-${build_version}" configure -j ${num_threads};
  (cd "${build_path}/bash-${build_version}" && ./configure --prefix="${inst_path}");
  make -C "${build_path}/bash-${build_version}" -j ${num_threads};
  make -C "${build_path}/bash-${build_version}" install -j ${num_threads};
  "${rm_bin}" -rf "${build_path}/bash-${build_version}" "${build_path}/bash-${build_version}.tar.gz";
  "${rm_bin}" -rf "${build_path}";
  "${inst_path}/bin/bash" --version;
}

# =============================================================================
# Install Pre-compiled binaries
# =============================================================================
function __install_yq () {
  local latest_version;
  local gh_repo;
  local get_url;
  local sys_arch bin_arch;
  local ln_bin chmod_bin;
  local link_inst_path;
  # local yq_available;
  # yq_available=$(is_available 'yq');
  # if [[ ${yq_available} == true ]]; then
  #   return 0;
  # fi
  inst_path="$(__install_path --user)";
  link_inst_path="${HOME}/.local/bin";
  # if [[ -f ${link_inst_path}/yq ]]; then
  # return 0;
  # fi
  sys_arch="$(uname -s)-$(uname -m)";
  case ${sys_arch} in
    Linux-x86_64)     bin_arch="linux_amd64"    ;;
    Linux-aarch64)    bin_arch="linux_arm64"    ;;
    Darwin-x86_64)    bin_arch="darwin_amd64"   ;;
    Darwin-arm64)     bin_arch="darwin_arm64"   ;;
    *)
      builtin echo >&2 -ne "Error: Unknown CPU architecture '${sys_arch}'\n";
      return 1;
    ;;
  esac
  ln_bin="$(which_bin 'ln')";
  chmod_bin="$(which_bin 'chmod')";
  gh_repo='mikefarah/yq';
  latest_version="$(__get_gh_latest_release ${gh_repo})";
  base_url="https://github.com/${gh_repo}/releases/download";
  get_url="${base_url}/${latest_version}/yq_${bin_arch}";
  mkdir -p "${inst_path}/yq/temp";
  download "${get_url}" "${inst_path}/yq/temp";
  "${chmod_bin}" +x "${inst_path}/yq/temp/yq_${bin_arch}";

  "${ln_bin}" -sf \
      "${inst_path}/yq/temp/yq_${bin_arch}" \
      "${link_inst_path}/yq";
  return 0;
}

# =============================================================================
# Bootstrap Python command line tools installation
# =============================================================================
function __install_python_cli_tools () {
  local py_bin;
  local pipx_bin;
  local pipx_pkg_arr;
  local _pipx_pkg;
  py_bin="$(which_bin 'python3')";
  if [[ -z ${py_bin} ]]; then
    py_bin="$(which_bin 'python')";
  fi
  "${py_bin}" -m pip \
    install --user \
    pipx;
  pipx_bin="$(which_bin 'pipx')";
  builtin mapfile -t pipx_pkg_arr < <(get_config 'python_packages' 'pipx');
  for _pipx_pkg in "${pipx_pkg_arr[@]}"; do
    "${pipx_bin}" install "${_pipx_pkg}";
  done
}

# =============================================================================
# Bootstrap R environment
# =============================================================================


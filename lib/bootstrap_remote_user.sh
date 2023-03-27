#!/usr/bin/env bash

# Main function to install tools and
# + reload user environment
function bootstrap_user () {
  local install_type;
  local mkdir_bin;
  install_type='--user';
  mkdir_bin="$(require 'mkdir')";
  "${mkdir_bin}" -p "${HOME}/projects";
  "${mkdir_bin}" -p "${HOME}/workspaces";
  "${mkdir_bin}" -p "${HOME}/.local/bin";
  "${mkdir_bin}" -p "${HOME}/.local/lib";
  "${mkdir_bin}" -p "${HOME}/.local/opt/apps";

  # TODO: @luciorq Finish adding required tools
  __check_req_cli_tools;

  __build_git "${install_type}";
  __install_yq;
  __build_bash "${install_type}";
  __install_python_cli_tools;
  __build_rust_cargo "${install_type}";
  __clean_home;
  install_apps "${install_type}";
  __rebuild_rust_source_tools;
  __install_node_cli_tools;
  source_configs;
  __clean_home;
  __update_configs;
  return 0;
}

# Check for required system tools
function __check_req_cli_tools () {
  local cli_arr;
  local _cli;
  local cli_bin;
  declare -a cli_arr=(
    curl
    gcc
    npm
    git
    rsync
  )
  for _cli in "${cli_arr[@]}"; do
    cli_bin=$(require "${_cli}");
    if [[ -z ${cli_bin} ]]; then
      builtin echo -ne "Install '${_cli}' to continue.\n";
    fi
  done
  return 0;
}


# Clean dotfiles not XDG base dir spec
# + compliant in user home dir
function __clean_home () {
  local remove_dirs_arr;
  local _dir;
  local rm_bin;
  local path_to_rm;
  rm_bin="$(which_bin 'rm')";
  # TODO: @luciorq Add .mamba, after solving xdg compliance to .mamba/proc/
  declare -a remove_dirs_arr=(
    .vim
    .vimrc
    .viminfo
    .npm
    .gem
    .sudo_as_admin_successful
    .wget-hsts
    .lesshst
    .python_history
    .radian_history
    .subversion
    .conda
    .mamba
    .pki
    .rnd
    .Rhistory
    .bash_profile
    .bash_history
    .zshenv
    .zshrc
    .kitty-ssh-kitten*
    .thunderbird
    .TinyTeX
    .gnome
    .nextflow
    .fluffy
    .mozilla
    .groovy
    .openjfx
    .emacs
    .android
    .docker
    .spack
    .dockstore
    .git-credentials
    .minikube
    .mini-kube
    .terminfo
    .keras
    .Xauthority
    .yarnrc
    .yarn
  )
  for _dir in "${remove_dirs_arr[@]}"; do
    path_to_rm="${HOME}/${_dir}";
    if [[ -f ${path_to_rm} ]]; then
      "${rm_bin}" -f "${path_to_rm}";
    elif [[ -d ${path_to_rm} ]]; then
      "${rm_bin}" -rf "${path_to_rm}";
    fi
  done;

  return 0;
}

# ======================================================================
# Build Tools from source
# ======================================================================

# Build Cargo and Rustup
function __build_rust_cargo () {
  local cargo_bin;
  local curl_bin;
  local bash_bin;
  local ln_bin;
  local ls_bin;
  local install_path;
  local link_path;
  local cargo_path;
  local _link_bin;
  local link_bin_arr;
  cargo_bin="$(which_bin 'cargo')";
  install_path="${HOME}/.local/share/cargo/bin";
  link_path="${HOME}/.local/bin";
  cargo_path="${install_path}/cargo";
  if [[ -z ${cargo_bin} ]]; then
    if [[ ! -f ${cargo_path} ]]; then
      curl_bin="$(require 'curl')";
      bash_bin="$(require 'bash')";
      "${bash_bin}" <(
        "${curl_bin}" --proto '=https' --tlsv1.2 -sSf 'https://sh.rustup.rs'
      ) --no-modify-path --quiet -y;
    fi
    ln_bin="$(require 'ln')";
    ls_bin="$(require 'ls')";
    builtin mapfile -t link_bin_arr < <(
      "${ls_bin}" -A1 "${install_path}"
    );
    for _link_bin in "${link_bin_arr[@]}"; do
      "${ln_bin}" -sf \
        "${install_path}/${_link_bin}" \
        "${link_path}/${_link_bin}";
    done
  fi
  rustup_bin="$(which_bin 'rustup')";
  if [[ -n ${rustup_bin} ]]; then
    "${rustup_bin}" default stable;
  fi
  return 0;
}

# Rebuild specific Rust app using local cargo
function __rebuild_rust_source_app () {
  local _usage="usage: ${0} <CARGO_PKG_NAME> <APP_BINARIY>";
  unset _usage;
  local pkg_name;
  local app_bin;
  local cargo_bin;
  local ln_bin;
  local install_path;
  local link_path;
  pkg_name="${1}";
  app_bin="${2}";
  if [[ ${#} -lt 2 ]]; then
    exit_fun 'This function needs two arguments';
    return 1;
  fi
  cargo_bin="$(require 'cargo')";
  ln_bin="$(require 'ln')";
  install_path="${HOME}/.local/opt/apps/temp";
  link_path="${HOME}/.local/bin"
  "${cargo_bin}" install --quiet \
    --root "${install_path}" "${pkg_name}";
  "${ln_bin}" -sf "${install_path}/bin/${app_bin}" \
    "${link_path}/${app_bin}";
  return 0;
}

# Rebuild all Rust app that fails to pass test
# + Main motivation for this function was that most
# + pre-compiled binaries available omn GitHub repositories
# + fail to work on CentOS/RHEL 7 because of older GLIBC
function __rebuild_rust_source_tools () {
  local install_path;
  local link_path;
  local cargo_arr;
  local app_bin_arr;
  local _app_bin;
  local _app_bin_path;
  local cargo_bin;
  local ls_bin;
  local ln_bin;
  local check_bin_arr;
  local _check_name;
  local _check_bin;
  local rebuild_arr;
  local _check_avail;
  declare -a cargo_arr=(
    starship
    exa
    bat
    du-dust
    fd-find
    sd
    hck
  );
  cargo_bin="$(which_bin 'cargo')";
  ls_bin="$(require 'ls')";
  ln_bin="$(require 'ln')";
  install_path="${HOME}/.local/opt/apps/temp";
  link_path="${HOME}/.local/bin";
  declare -a check_bin_arr=(
    starship
    exa
    bat
    dust
    fd
    sd
    hck
  );
  declare -a rebuild_arr=();
  for _check_name in "${check_bin_arr[@]}"; do
    _check_bin="$(which_bin "${_check_name}")";
    if [[ -n ${_check_bin} ]]; then
      _check_avail="$(
        "${_check_bin}" --version 2> /dev/null > /dev/null \
          || builtin echo -ne "${?}"
      )";
      if [[ -n ${_check_avail} ]]; then
        rebuild_arr+=(
          "${_check_name}"
        );
      fi
    fi
  done
  if [[ ${#rebuild_arr[@]} -eq 0 ]]; then
    builtin echo -ne "No cargo app to rebuild.\n";
    return 0;
  fi
  "${cargo_bin}" install \
    --quiet \
    --root "${install_path}" \
    "${cargo_arr[@]}";
  builtin mapfile -t app_bin_arr < <(
    "${ls_bin}" -A1 "${install_path}/bin"
  );
  for _app_bin in "${app_bin_arr[@]}"; do
    _app_bin_path="${install_path}/bin/${_app_bin}";
    "${ln_bin}" -sf \
      "${_app_bin_path}" \
      "${link_path}/${_app_bin}";
  done
  return 0;
}

# Check version of the GLIBC library which the OS is built
function __check_glibc () {
  local glibc_version;
  local ldd_bin;
  local latest_version;
  local min_version;
  ldd_bin="$(which_bin 'ldd')";
  if [[ -z ${ldd_bin} ]]; then
    return 0;
  fi
  min_version="${1:-2.18}";
  glibc_version="$(
    builtin echo -ne "$("${ldd_bin}" --version ldd)" \
      | head -n1 \
      | sed -e 's/.*[[:space:]]//g'
  )";
  latest_version="$(
    builtin echo -ne "${glibc_version}\n${min_version}\n" \
      | sort -r -V \
      | head -n1
  )";
  if [[ ${latest_version} =~ ${glibc_version} ]]; then
    builtin echo -ne 'true';
  else
    builtin echo -ne 'false';
  fi
  return 0;
}

# Build the latest version of GLIBC in a user owned directory
function __build_glibc () {
  local glibc_right;
  local inst_path;
  local app_name;
  local mirror_repo;
  local make_bin;
  local latest_tag;
  local latest_version;
  local build_version;
  local num_threads;
  local get_url;
  local rm_bin;
  local mkdir_bin;
  local make_bin;
  local grep_bin;
  local sed_bin;
  local sort_bin;
  local curl_bin;
  local build_path;
  local install_type;
  local force_version;
  local __build_app_glibc;
  install_type="${1:---user}";
  force_version="${2:-latest}";
  inst_path="${HOME}/.local/opt/apps/${app_name}";
  if [[ ${install_type} == --system ]]; then
    inst_path="/opt/apps/${app_name}";
  fi
  app_name='glibc';
  if [[ ! ${OSTYPE} =~ "linux" ]]; then
    return 0;
  fi
  if [[ -z ${2} ]]; then
    glibc_right="$(__check_glibc '2.18')";
  else
    glibc_right='false';
  fi
  if [[ ${glibc_right} =~ "true" ]]; then
    return 0;
  fi
  rm_bin="$(which_bin 'rm')";
  mkdir_bin="$(which_bin 'mkdir')";
  grep_bin="$(which_bin 'grep')";
  sed_bin="$(which_bin 'sed')";
  sort_bin="$(which_bin 'sort')";
  curl_bin="$(which_bin 'curl')";
  make_bin="$(which_bin 'gmake')";
  if [[ -z ${make_bin} ]]; then
    make_bin="$(require 'make')";
  fi
  num_threads="$(get_nthreads 8)";
  if [[ ${force_version} == latest ]]; then
    mirror_repo='bminor/glibc';
    latest_tag="$(
      "${curl_bin}" -fsSL --insecure \
        "https://api.github.com/repos/${mirror_repo}/tags"
    )";
    latest_version="$(
    builtin echo "${latest_tag[@]}" \
      | "${sed_bin}" 's/\(\"name\"\):/\n\1/g' \
      | "${grep_bin}" '"name"' \
      | "${sed_bin}" -e 's/\"name\"[[:space:]]\"\(.*\)/\1/g' \
      | "${sed_bin}" -e 's/\",//g' \
      | "${grep_bin}" -v '\-rc\|\-beta\|\-alpha\|devel' \
      | "${grep_bin}" -v '\.9...$' \
      | "${grep_bin}" -v '\.9.$' \
      | "${sed_bin}" -e 's/glibc\-//g' \
      | "${sort_bin}" -rV
    )";
    build_version="${latest_version/[[:space:]]*/}";
  else
    build_version="${force_version}";
  fi
  base_name="${app_name}-${build_version}";
  get_url="https://ftp.gnu.org/gnu/glibc/${base_name}.tar.gz";
  build_path="$(create_temp 'glibc-build')";
  download "${get_url}" "${build_path}";
  unpack "${build_path}/${base_name}.tar.gz" "${build_path}";
  "${mkdir_bin}" -p "${inst_path}";
  "${mkdir_bin}" -p "${build_path}/${base_name}/build";
  function __build_app_glibc () {
    (
      builtin cd "${build_path}/${base_name}/build" \
        || return 1;
      ../configure --prefix="${inst_path}"
    )
  };
  __build_app_glibc;
  unset __build_app_glibc;
  MAKE="$(which make)" "${make_bin}" \
    -C "${build_path}/${base_name}" -j "${num_threads}";
  MAKE="$(which make)" "${make_bin}" \
    -C "${build_path}/${base_name}" install -j "${num_threads}";
  "${rm_bin}" -rf \
    "${build_path}/${base_name}" \
    "${build_path}/${base_name}.tar.gz";
  "${rm_bin}" -rf "${build_path}";
  return 0;
}

# Build latest GIT core from source
function __build_git () {
  local build_path;
  local inst_path;
  local num_threads;
  local get_url;
  local rm_bin;
  local make_bin;
  local __build_app_git;
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
  num_threads="$(get_nthreads 8)";
  get_url='https://github.com/git/git/archive/refs/heads/main.zip';
  build_path="$(create_temp 'git-inst')";
  download "${get_url}" "${build_path}";
  unpack "${build_path}/main.zip" "${build_path}";
  "${make_bin}" -C "${build_path}/git-main" configure -j "${num_threads}"
  function __build_app_git () {
    (
      builtin cd "${build_path}/git-main" \
        || return 1;
      ./configure --prefix="${inst_path}";
    )
  };
  __build_app_git;
  unset __build_app_git;
  "${make_bin}" -C "${build_path}/git-main" -j "${num_threads}";
  "${make_bin}" -C "${build_path}/git-main" install -j "${num_threads}";
  "${rm_bin}" -rf "${build_path}/git-main" "${build_path}/main.zip";
  "${rm_bin}" -rf "${build_path}";
  "${inst_path}/bin/git" --version;
  return 0;
}

# Build latest version of BASH from source
function __build_bash () {
  local latest_tag;
  local latest_release_version;
  local mirror_repo;
  local build_version;
  local build_path;
  local inst_path;
  local num_threads;
  local get_url;
  local rm_bin;
  local make_bin;
  local curl_bin;
  local grep_bin;
  local sed_bin;
  local sort_bin;

  rm_bin="$(which_bin 'rm')";
  sort_bin="$(which_bin 'sort')";
  sed_bin="$(which_bin 'sed')";
  grep_bin="$(which_bin 'grep')";
  curl_bin="$(which_bin 'curl')";
  make_bin="$(which_bin 'gmake')";
  if [[ -z ${make_bin} ]]; then
    make_bin="$(require 'make')";
  fi
  # inst_path="$(__install_path --user)";
  inst_path="${HOME}/.local";
  if [[ -f ${inst_path}/bin/bash ]]; then
    return 0;
  fi
  mirror_repo='bminor/bash';
  latest_tag="$(
    "${curl_bin}" -fsSL --insecure \
      "https://api.github.com/repos/${mirror_repo}/tags"
  )";
  latest_release_version="$(
    builtin echo "${latest_tag[@]}" \
      | "${sed_bin}" 's/\(\"name\"\):/\n\1/g' \
      | "${grep_bin}" '"name"' \
      | "${sed_bin}" -e 's/\"name\"[[:space:]]\"\(.*\)/\1/g' \
      | "${sed_bin}" -e 's/\",//g' \
      | "${grep_bin}" -v '\-rc\|\-beta\|\-alpha\|devel' \
      | "${grep_bin}" 'bash' \
      | "${sed_bin}" 's/bash\-//g' \
      | "${sort_bin}" -rV
  )";
  build_version="${latest_release_version/[[:space:]]*/}";
  num_threads="$(get_nthreads 8)";
  get_url="https://ftp.gnu.org/gnu/bash/bash-${build_version}.tar.gz";
  build_path="$(create_temp bash-inst)";
  download "${get_url}" "${build_path}";
  unpack "${build_path}/bash-${build_version}.tar.gz" "${build_path}";
  local __build_app_bash;
  function __build_app_bash () {
    (
      builtin cd "${build_path}/bash-${build_version}" \
        || return 1;
      ./configure --prefix="${inst_path}";
    )
  };
  __build_app_bash;
  unset __build_app_bash;
  "${make_bin}" \
    -C "${build_path}/bash-${build_version}" -j "${num_threads}";
  "${make_bin}" \
    -C "${build_path}/bash-${build_version}" install -j "${num_threads}";
  "${rm_bin}" -rf \
    "${build_path}/bash-${build_version}" \
    "${build_path}/bash-${build_version}.tar.gz";
  "${rm_bin}" -rf "${build_path}";
  "${inst_path}/bin/bash" --version;
  return 0;
}

# ====================================================================
# Install Pre-compiled binaries
# ====================================================================

# Install a temporary yq binary to make parse_yaml work
function __install_yq () {
  local latest_version;
  local gh_repo;
  local get_url;
  local sys_arch bin_arch;
  local ln_bin chmod_bin mkdir_bin;
  local link_inst_path;
  inst_path="$(__install_path --user)";
  link_inst_path="${HOME}/.local/bin";
  sys_arch="$(uname -s)-$(uname -m)";
  case "${sys_arch}" in
    Linux-x86_64)     bin_arch="linux_amd64"    ;;
    Linux-aarch64)    bin_arch="linux_arm64"    ;;
    Darwin-x86_64)    bin_arch="darwin_amd64"   ;;
    Darwin-arm64)     bin_arch="darwin_arm64"   ;;
    *) exit_fun "Error: Unknown CPU architecture '${sys_arch}'\n" ;;
  esac
  ln_bin="$(require 'ln')";
  chmod_bin="$(require 'chmod')";
  mkdir_bin="$(require 'mkdir')";
  gh_repo='mikefarah/yq';
  latest_version="$(__get_gh_latest_release "${gh_repo}")";
  base_url="https://github.com/${gh_repo}/releases/download";
  get_url="${base_url}/${latest_version}/yq_${bin_arch}";
  "${mkdir_bin}" -p "${inst_path}/yq/temp";
  download "${get_url}" "${inst_path}/yq/temp";
  "${chmod_bin}" +x "${inst_path}/yq/temp/yq_${bin_arch}";
  if [[ ! -d ${link_inst_path} ]]; then
    "${mkdir_bin}" -p "${link_inst_path}";
  fi
  "${ln_bin}" -sf \
    "${inst_path}/yq/temp/yq_${bin_arch}" \
    "${link_inst_path}/yq";
  return 0;
}

# ===================================================================
# Bootstrap NodeJs command line tools installation
# ===================================================================

# Use NPM to install NODEJS-based system tools
function __install_node_cli_tools () {
  local npm_bin;
  local npm_pkg_arr;
  local _npm_pkg;
  local npm_exec_arr;
  local _npm_exec;
  local ls_bin;
  local ln_bin;

  ls_bin="$(which_bin 'ls')";
  ln_bin="$(which_bin 'ln')";
  npm_bin="$(which_bin 'npm')";
  if [[ -z ${npm_bin} ]]; then
    builtin echo -ne "'npm' is not installed\n";
    return 0;
  fi
  "${npm_bin}" install -g npm;
  builtin mapfile -t npm_pkg_arr < <(
    get_config 'node_packages' 'npm'
  );
  for _npm_pkg in "${npm_pkg_arr[@]}"; do
    "${npm_bin}" install -g "${_npm_pkg}";
  done
  builtin mapfile -t npm_exec_arr < <(
    "${ls_bin}" -A1 "${HOME}/.local/share/npm/bin"
  );
  for _npm_exec in "${npm_exec_arr[@]}"; do
    "${ln_bin}" -sf \
      "${HOME}/.local/share/npm/bin/${_npm_exec}" \
      "${HOME}/.local/bin/${_npm_exec}";
  done
  return 0;
}

# ===================================================================
# Bootstrap Python command line tools installation
# ===================================================================

# Install Python Packages in the Mamba based latest Python installation
function __install_python_cli_tools () {
  local py_bin;
  local pip_pkg_arr;
  local _pip_pkg;
  local ln_bin;
  __install_app --user 'micromamba';
  __install_app --user 'python';
  ln_bin="$(which_bin 'ln')";
  py_bin="$(which_bin 'python3')";
  if [[ -z ${py_bin} ]]; then
    py_bin="$(which_bin 'python')";
  fi
  builtin mapfile -t pip_pkg_arr < <(
    get_config 'python_packages' 'pip'
  );
  for _pip_pkg in "${pip_pkg_arr[@]}"; do
    "${py_bin}" -m pip install "${_pip_pkg}";
  done
  return 0;
}

# ===================================================================
# Bootstrap R environment
# ===================================================================

# TODO: @luciorq Check rstats::install_all_pkgs
# Install R packages to local installation of R
#function __install_rstats_packages () {
# return 0;
#}

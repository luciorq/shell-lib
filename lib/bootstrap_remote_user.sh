#!/usr/bin/env bash

# Main function to install tools and
# + reload user environment
function bootstrap_user () {
  \builtin local install_type;
  \builtin local mkdir_bin;
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
  clean_pixi_and_conda_cache;
  clean_homebrew_cache;
  clean_rstats_cache;
  \builtin return 0;
}

# Clean Homebrew cache
function clean_homebrew_cache () {
  \builtin local brew_bin;
  \builtin local rm_bin;
  brew_bin="$(which_bin 'brew')";
  rm_bin="$(which_bin 'rm')";
  if [[ -n ${brew_bin} ]]; then
    "${brew_bin}" cleanup;
    "${brew_bin}" cleanup -s;
    "${brew_bin}" cleanup --prune=all;
    "${rm_bin}" -rf "$("${brew_bin}" --cache)";
  fi
  \builtin return 0;
}

# Clean R cache
# function

# Check for required system tools
function __check_req_cli_tools () {
  \builtin local cli_arr;
  \builtin local _cli;
  \builtin local cli_bin;
  # cli_arr='';
  \builtin declare -a cli_arr;
  cli_arr=(
    curl
    gcc
    npm
    git
    rsync
  )
  for _cli in "${cli_arr[@]}"; do
    cli_bin=$(require "${_cli}");
    if [[ -z ${cli_bin} ]]; then
      \builtin echo -ne "Install '${_cli}' to continue.\n";
    fi
  done
  \builtin return 0;
}

# Clean configuration and dotfiles not in XDG base dir spec
# + compliant in user home directory
function __clean_home () {
  \builtin local remove_dirs_arr;
  \builtin local _dir;
  \builtin local rm_bin;
  \builtin local path_to_rm;
  rm_bin="$(require 'rm')";
  if [[ -z ${rm_bin} ]]; then
    exit_fun "'rm' command not available on \${PATH}";
    \builtin return 1;
  fi
  # remove_dirs_arr='';
  \builtin declare -a remove_dirs_arr;
  remove_dirs_arr=(
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
    .ipynb_checkpoints
    .subversion
    .conda
    .mamba
    .nv
    .ncbi
    .pki
    .rnd
    .duckdb
    .Rhistory
    .bash_profile
    .bash_history
    .shell_history
    .zshenv
    .zshrc
    .kitty-ssh-kitten*
    .thunderbird
    .TinyTeX
    .gnome
    .nextflow
    .fluffy
    .mozilla
    .links
    .groovy
    .openjfx
    .emacs
    .rustup
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
    .slime_paste
    .virtual_documents
    .DS_Store
  )
  for _dir in "${remove_dirs_arr[@]}"; do
    path_to_rm="${HOME}/${_dir}";
    if [[ -f ${path_to_rm} ]]; then
      "${rm_bin}" -f "${path_to_rm}";
    elif [[ -d ${path_to_rm} ]]; then
      "${rm_bin}" -rf "${path_to_rm}";
    fi
  done;

  if [[ -d "${HOME}/.Trash" ]]; then
    "${rm_bin}" -rf "${HOME}"/.Trash/*;
    "${rm_bin}" -rf "${HOME}"/.Trash/.*;
  fi
  \builtin return 0;
}

# ======================================================================
# Build Tools from source
# ======================================================================

# Build Cargo and Rustup
function __build_rust_cargo () {
  \builtin local cargo_bin;
  \builtin local curl_bin;
  \builtin local bash_bin;
  \builtin local ln_bin;
  \builtin local ls_bin;
  \builtin local install_path;
  \builtin local link_path;
  \builtin local cargo_path;
  \builtin local _link_bin;
  \builtin local link_bin_arr;
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
    \builtin mapfile -t link_bin_arr < <(
      LC_ALL=C "${ls_bin}" -A1 -- "${install_path}"
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
  \builtin return 0;
}

# Rebuild specific Rust app using local cargo
function __rebuild_rust_source_app () {
  \builtin local _usage;
  _usage="usage: ${0} <CARGO_PKG_NAME> <APP_BINARIY>";
  \builtin unset _usage;
  \builtin local pkg_name;
  \builtin local app_bin;
  \builtin local cargo_bin;
  \builtin local ln_bin;
  \builtin local install_path;
  \builtin local link_path;
  pkg_name="${1:-}";
  app_bin="${2:-}";
  if [[ ${#:-0} -lt 2 ]]; then
    exit_fun 'This function needs two arguments';
    \builtin return 1;
  fi
  cargo_bin="$(require 'cargo')";
  ln_bin="$(require 'ln')";
  install_path="${HOME}/.local/opt/apps/temp";
  link_path="${HOME}/.local/bin"
  "${cargo_bin}" install --quiet \
    --root "${install_path}" "${pkg_name}";
  "${ln_bin}" -sf "${install_path}/bin/${app_bin}" \
    "${link_path}/${app_bin}";
  \builtin return 0;
}

# Rebuild all Rust app that fails to pass test
# + Main motivation for this function was that most
# + pre-compiled binaries available omn GitHub repositories
# + fail to work on CentOS/RHEL 7 because of older GLIBC
function __rebuild_rust_source_tools () {
  \builtin local install_path;
  \builtin local link_path;
  \builtin local cargo_arr;
  \builtin local app_bin_arr;
  \builtin local _app_bin;
  \builtin local _app_bin_path;
  \builtin local cargo_bin;
  \builtin local ls_bin;
  \builtin local ln_bin;
  \builtin local check_bin_arr;
  \builtin local _check_name;
  \builtin local _check_bin;
  \builtin local rebuild_arr;
  \builtin local _check_avail;
  \builtin declare -a cargo_arr;
  cargo_arr=(
    starship
    eza
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
  \builtin declare -a check_bin_arr;
  check_bin_arr=(
    starship
    eza
    bat
    dust
    fd
    sd
    hck
  );
  \builtin declare -a rebuild_arr;
  rebuild_arr=();
  for _check_name in "${check_bin_arr[@]}"; do
    _check_bin="$(which_bin "${_check_name}")";
    if [[ -n ${_check_bin} ]]; then
      _check_avail="$(\
        "${_check_bin}" --version 2> /dev/null > /dev/null \
          || \builtin echo -ne "${?}"\
      )";
      if [[ -n ${_check_avail} ]]; then
        rebuild_arr+=(
          "${_check_name}"
        );
      fi
    fi
  done
  if [[ ${#rebuild_arr[@]} -eq 0 ]]; then
    \builtin echo -ne "No cargo app to rebuild.\n";
    \builtin return 0;
  fi
  "${cargo_bin}" install \
    --quiet \
    --root "${install_path}" \
    "${cargo_arr[@]}";
  \builtin mapfile -t app_bin_arr < <(
    LC_ALL=C "${ls_bin}" -A1 -- "${install_path}/bin"
  );
  for _app_bin in "${app_bin_arr[@]}"; do
    _app_bin_path="${install_path}/bin/${_app_bin}";
    "${ln_bin}" -sf \
      "${_app_bin_path}" \
      "${link_path}/${_app_bin}";
  done
  \builtin return 0;
}

# Check version of the GLIBC library which the OS is built
function __check_glibc () {
  \builtin local glibc_version;
  \builtin local ldd_bin;
  \builtin local latest_version;
  \builtin local min_version;
  ldd_bin="$(which_bin 'ldd')";
  if [[ -z ${ldd_bin} ]]; then
    exit_fun '__check_glibc: `ldd` not found';
    \builtin return 0;
  fi
  min_version="${1:-2.18}";
  glibc_version="$(
    \builtin echo -ne "$("${ldd_bin}" --version ldd)" \
      | head -n1 \
      | sed -e 's/.*[[:space:]]//g'
  )";
  latest_version="$(\
    \builtin echo -ne "${glibc_version}\n${min_version}\n" \
      | sort -r -V \
      | head -n1\
  )";
  if [[ ${latest_version} =~ ${glibc_version} ]]; then
    \builtin echo -ne 'true';
  else
    \builtin echo -ne 'false';
  fi
  \builtin return 0;
}

# Build the latest version of GLIBC in a user owned directory
function __build_glibc () {
  \builtin local glibc_right;
  \builtin local inst_path;
  \builtin local app_name;
  \builtin local mirror_repo;
  \builtin local make_bin;
  \builtin local latest_tag;
  \builtin local latest_version;
  \builtin local build_version;
  \builtin local num_threads;
  \builtin local get_url;
  \builtin local rm_bin;
  \builtin local mkdir_bin;
  \builtin local make_bin;
  \builtin local grep_bin;
  \builtin local sed_bin;
  \builtin local sort_bin;
  \builtin local curl_bin;
  \builtin local build_path;
  \builtin local install_type;
  \builtin local force_version;
  \builtin local __build_app_glibc;
  install_type="${1:---user}";
  force_version="${2:-latest}";
  inst_path="${HOME}/.local/opt/apps/${app_name}";
  if [[ ${install_type} == --system ]]; then
    inst_path="/opt/apps/${app_name}";
  fi
  app_name='glibc';
  if [[ ! ${OSTYPE:-} =~ "linux" ]]; then
    \builtin return 0;
  fi
  if [[ -z ${force_version} ]]; then
    glibc_right="$(__check_glibc '2.18')";
  else
    glibc_right='false';
  fi
  if [[ ${glibc_right} =~ "true" ]]; then
    \builtin return 0;
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
    latest_tag="$(\
      "${curl_bin}" -fsSL --insecure \
        "https://api.github.com/repos/${mirror_repo}/tags"\
    )";
    latest_version="$(
    \builtin echo "${latest_tag[@]}" \
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
      \builtin cd "${build_path}/${base_name}/build" \
        || \builtin return 1;
      ../configure --prefix="${inst_path}"
    )
  };
  __build_app_glibc;
  \builtin unset __build_app_glibc;
  MAKE="$(which make)" "${make_bin}" \
    -C "${build_path}/${base_name}" -j "${num_threads}";
  MAKE="$(which make)" "${make_bin}" \
    -C "${build_path}/${base_name}" install -j "${num_threads}";
  "${rm_bin}" -rf \
    "${build_path}/${base_name}" \
    "${build_path}/${base_name}.tar.gz";
  "${rm_bin}" -rf "${build_path}";
  \builtin return 0;
}

# Build latest GIT core from source
function __build_git () {
  \builtin local build_path;
  \builtin local inst_path;
  \builtin local num_threads;
  \builtin local get_url;
  \builtin local rm_bin;
  \builtin local make_bin;
  \builtin local __build_app_git;
  rm_bin="$(which_bin 'rm')";
  make_bin="$(which_bin 'gmake')";
  if [[ -z ${make_bin} ]]; then
    make_bin="$(require 'make')";
  fi
  # inst_path="$(__install_path --user)";
  inst_path="${HOME}/.local";
  if [[ -f ${inst_path}/bin/git ]]; then
    \builtin return 0;
  fi
  num_threads="$(get_nthreads 8)";
  get_url='https://github.com/git/git/archive/refs/heads/main.zip';
  build_path="$(create_temp 'git-inst')";
  download "${get_url}" "${build_path}";
  unpack "${build_path}/main.zip" "${build_path}";
  "${make_bin}" -C "${build_path}/git-main" configure -j "${num_threads}"
  function __build_app_git () {
    (
      \builtin cd "${build_path}/git-main" \
        || \builtin return 1;
      ./configure --prefix="${inst_path}";
    )
  };
  __build_app_git;
  \builtin unset __build_app_git;
  "${make_bin}" -C "${build_path}/git-main" -j "${num_threads}";
  "${make_bin}" -C "${build_path}/git-main" install -j "${num_threads}";
  "${rm_bin}" -rf "${build_path}/git-main" "${build_path}/main.zip";
  "${rm_bin}" -rf "${build_path}";
  "${inst_path}/bin/git" --version;
  \builtin return 0;
}

# Build latest version of BASH from source
function __build_bash () {
  \builtin local latest_tag;
  \builtin local latest_release_version;
  \builtin local mirror_repo;
  \builtin local build_version;
  \builtin local build_path;
  \builtin local inst_path;
  \builtin local num_threads;
  \builtin local get_url;
  \builtin local rm_bin;
  \builtin local make_bin;
  \builtin local curl_bin;
  \builtin local grep_bin;
  \builtin local sed_bin;
  \builtin local sort_bin;

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
    \builtin return 0;
  fi
  mirror_repo='bminor/bash';
  latest_tag="$(
    "${curl_bin}" -fsSL --insecure \
      "https://api.github.com/repos/${mirror_repo}/tags"
  )";
  latest_release_version="$(
    \builtin echo "${latest_tag[@]}" \
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
      \builtin cd "${build_path}/bash-${build_version}" \
        || \builtin return 1;
      ./configure --prefix="${inst_path}";
    )
  };
  __build_app_bash;
  \builtin unset __build_app_bash;
  "${make_bin}" \
    -C "${build_path}/bash-${build_version}" -j "${num_threads}";
  "${make_bin}" \
    -C "${build_path}/bash-${build_version}" install -j "${num_threads}";
  "${rm_bin}" -rf \
    "${build_path}/bash-${build_version}" \
    "${build_path}/bash-${build_version}.tar.gz";
  "${rm_bin}" -rf "${build_path}";
  "${inst_path}/bin/bash" --version;
  \builtin return 0;
}

# ====================================================================
# Install Pre-compiled binaries
# ====================================================================

# Install a temporary yq binary to make parse_yaml work
function __install_yq () {
  \builtin local latest_version;
  \builtin local gh_repo;
  \builtin local get_url;
  \builtin local sys_arch;
  \builtin local bin_arch;
  \builtin local ln_bin;
  \builtin local chmod_bin;
  \builtin local mkdir_bin;
  \builtin local uname_bin;
  \builtin local link_inst_path;
  inst_path="$(__install_path --user)";
  link_inst_path="${HOME}/.local/bin";
  uname_bin="$(require 'uname')";
  sys_arch="$("${uname_bin}" -s)-$("${uname_bin}" -m)";
  case "${sys_arch}" in
    Linux-x86_64)     bin_arch="linux_amd64"    ;;
    Linux-aarch64)    bin_arch="linux_arm64"    ;;
    Darwin-x86_64)    bin_arch="darwin_amd64"   ;;
    Darwin-arm64)     bin_arch="darwin_arm64"   ;;
    *) exit_fun "Unknown CPU architecture '${sys_arch}'\n" ;;
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
  \builtin return 0;
}

# ===================================================================
# Bootstrap NodeJs command line tools installation
# ===================================================================

# Use NPM to install NODEJS-based system tools
function __install_node_cli_tools () {
  \builtin local npm_bin;
  \builtin local npm_pkg_arr;
  \builtin local _npm_pkg;
  \builtin local npm_exec_arr;
  \builtin local _npm_exec;
  \builtin local ls_bin;
  \builtin local ln_bin;

  ls_bin="$(which_bin 'ls')";
  ln_bin="$(which_bin 'ln')";
  npm_bin="$(which_bin 'npm')";
  if [[ -z ${npm_bin} ]]; then
    \builtin echo -ne "'npm' is not installed\n";
    \builtin return 0;
  fi
  "${npm_bin}" install -g npm;
  npm_pkg_arr='';
  \builtin mapfile -t npm_pkg_arr < <(
    get_config 'node_packages' 'npm'
  );
  for _npm_pkg in "${npm_pkg_arr[@]}"; do
    "${npm_bin}" install -g "${_npm_pkg}";
  done
  npm_exec_arr='';
  \builtin mapfile -t npm_exec_arr < <(
    LC_ALL=C "${ls_bin}" -A1 -- "${HOME}/.local/share/npm/bin"
  );
  for _npm_exec in "${npm_exec_arr[@]}"; do
    "${ln_bin}" -sf \
      "${HOME}/.local/share/npm/bin/${_npm_exec}" \
      "${HOME}/.local/bin/${_npm_exec}";
  done
  \builtin return 0;
}

# ===================================================================
# Bootstrap Python command line tools installation
# ===================================================================

# Install Python Packages in the Mamba based latest Python installation
function __install_python_cli_tools () {
  \builtin local py_bin;
  \builtin local pip_pkg_arr;
  \builtin local _pip_pkg;
  \builtin local ln_bin;
  __install_app --user 'micromamba';
  __install_app --user 'python';
  ln_bin="$(which_bin 'ln')";
  py_bin="$(which_bin 'python3')";
  if [[ -z ${py_bin} ]]; then
    py_bin="$(which_bin 'python')";
  fi
  pip_pkg_arr='';
  \builtin mapfile -t pip_pkg_arr < <(
    get_config 'python_packages' 'pip'
  );
  for _pip_pkg in "${pip_pkg_arr[@]}"; do
    "${py_bin}" -m pip install "${_pip_pkg}";
  done
  \builtin return 0;
}

# ===================================================================
# Bootstrap R environment
# ===================================================================

# TODO: @luciorq Check rstats_install_all_pkgs
# Install R packages to local installation of R
#function __install_rstats_packages () {
# \builtin return 0;
#}

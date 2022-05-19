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
  __build_git "${install_type}";
  __install_yq;
  __build_bash "${install_type}";
  __install_python_cli_tools;
  # __build_glibc "${install_type}";
  __build_rust_cargo "${install_type}";
  install_apps "${install_type}";
  __build_rust_cargo_tools;
  __install_node_cli_tools;
  source_configs;
  __clean_home;
  __update_configs;
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
    .bash_history
    .wget-hsts
    .python_history
    .subversion
    .mamba
    .Rhistory
    .bash_profile
    .zshenv
    .zshrc
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
function __build_rust_cargo () {
  local cargo_bin;
  local cargo_path;
  cargo_bin="$(which_bin 'cargo')";
  cargo_path="${HOME}/.local/share/cargo/bin/cargo";

  if [[ -z ${cargo_bin} ]]; then
    if [[ ! -f ${cargo_path} ]]; then
      bash \
        <(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs) \
        --no-modify-path --quiet -y;
    fi
    ln -sf \
      "${HOME}/.local/share/cargo/bin/cargo" \
      "${HOME}/.bin/cargo"
  fi
  return 0;
}

function __build_rust_cargo_tools () {
  local cargo_bin;
  local install_path;
  local cargo_arr;
  local bin_arr;
  local _bin;
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
  install_path="${HOME}/.local/opt/apps/temp";
  if [[]]; then
    "${cargo_bin}" install --quiet \
      --root "${install_path}" ${cargo_arr[*]};
  fi
  return 0;
}

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
  local build_path;
  local install_type;
  local force_version;
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

  # if [[ ${force_version} == latest ]]; then
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
  make_bin="$(which_bin 'gmake')";
  if [[ -z ${make_bin} ]]; then
    make_bin="$(require 'make')";
  fi
  num_threads="$(get_nthreads 8)";

  if [[ ${force_version} == latest ]]; then
    mirror_repo='bminor/glibc';
    latest_tag="$(
      curl -fsSL "https://api.github.com/repos/${mirror_repo}/tags"
    )";
    latest_version="$(
    builtin echo "${latest_tag[@]}" \
      | sed 's/\(\"name\"\):/\n\1/g' \
      | grep '"name"' \
      | sed -e 's/\"name\"[[:space:]]\"\(.*\)/\1/g' \
      | sed -e 's/\",//g' \
      | grep -v '\-rc\|\-beta\|\-alpha\|devel' \
      | grep -v '\.9...$' \
      | grep -v '\.9.$' \
      | sed -e 's/glibc\-//g' \
      | sort -rV
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
  "${mkdir_bin}" -p "${build_path}/${base_name}/build"

  (cd "${build_path}/${base_name}/build" && ../configure --prefix="${inst_path}");
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
  num_threads="$(get_nthreads 8)";
  get_url='https://github.com/git/git/archive/refs/heads/main.zip';
  build_path="$(create_temp 'git-inst')";
  download "${get_url}" "${build_path}";
  unpack "${build_path}/main.zip" "${build_path}";
  "${make_bin}" -C "${build_path}/git-main" configure -j "${num_threads}";
  (cd "${build_path}/git-main" && ./configure --prefix="${inst_path}");
  "${make_bin}" -C "${build_path}/git-main" -j "${num_threads}";
  "${make_bin}" -C "${build_path}/git-main" install -j "${num_threads}";
  "${rm_bin}" -rf "${build_path}/git-main" "${build_path}/main.zip";
  "${rm_bin}" -rf "${build_path}";
  "${inst_path}/bin/git" --version;
  return 0;
}

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

  rm_bin="$(which_bin 'rm')";
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
    curl -fsSL "https://api.github.com/repos/${mirror_repo}/tags"
  )";
  latest_release_version="$(
    builtin echo "${latest_tag[@]}" \
      | sed 's/\(\"name\"\):/\n\1/g' \
      | grep '"name"' \
      | sed -e 's/\"name\"[[:space:]]\"\(.*\)/\1/g' \
      | sed -e 's/\",//g' \
      | grep -v '\-rc\|\-beta\|\-alpha\|devel' \
      | grep 'bash' \
      | sed 's/bash\-//g' \
      | sort -rV
  )";
  build_version="${latest_release_version/[[:space:]]*/}";
  num_threads="$(get_nthreads 8)";
  get_url="https://ftp.gnu.org/gnu/bash/bash-${build_version}.tar.gz";
  build_path="$(create_temp bash-inst)";
  download "${get_url}" "${build_path}";
  unpack "${build_path}/bash-${build_version}.tar.gz" "${build_path}";
  # "${make_bin}" -C "${build_path}/bash-${build_version}" configure -j ${num_threads};
  (cd "${build_path}/bash-${build_version}" && ./configure --prefix="${inst_path}");
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


# =============================================================================
# Install Pre-compiled binaries
# =============================================================================
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

  "${ln_bin}" -sf \
      "${inst_path}/yq/temp/yq_${bin_arch}" \
      "${link_inst_path}/yq";
  return 0;
}

# =============================================================================
# Bootstrap NodeJs command line tools installation
# =============================================================================
function __install_node_cli_tools () {
  local npm_bin;
  local npm_pkg_arr;
  local _npm_pkg;
  local npm_exec_arr;
  local _npm_exec;
  npm_bin="$(which_bin 'npm')";
  if [[ -z ${npm_bin} ]]; then
    builtin echo -ne "'npm' is not installed\n";
    return 0;
  fi
  "${npm_bin}" install -g npm;
  builtin mapfile -t npm_pkg_arr < <(get_config 'node_packages' 'npm');
  for _npm_pkg in "${npm_pkg_arr[@]}"; do
    "${npm_bin}" install -g "${_npm_pkg}";
  done
  builtin mapfile -t npm_exec_arr < <(
    \ls -A1 "${HOME}/.local/share/npm/bin"
  );
  for _npm_exec in "${npm_exec_arr[@]}"; do
    \ln -sf \
      "${HOME}/.local/share/npm/bin/${_npm_exec}" \
      "${HOME}/.local/bin/${_npm_exec}";
  done
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
  local ln_bin;
  __install_app --user 'micromamba';
  __install_app --user 'python';
  __install_app --user 'pipx';
  py_bin="$(which_bin 'python3')";
  ln_bin="$(which_bin '')";
  pipx_bin="$(require 'pipx')";
  builtin mapfile -t pipx_pkg_arr < <(get_config 'python_packages' 'pipx');
  for _pipx_pkg in "${pipx_pkg_arr[@]}"; do
    "${pipx_bin}" install "${_pipx_pkg}";
  done
  return 0;
}

# =============================================================================
# Bootstrap R environment
# =============================================================================


#!/usr/bin/env bash

# Install programming language from conda-forge pre-compiled binaries
function install_lang () {
  local app_usage="Usage:  install_lang <LANG_APP> <VERSION> <INSTALL_PATH> [<link=true>]"
  if [[ "$#" == 0 || "$1" == -h || "$1" == --help ]]; then
    builtin echo >&2 "${app_usage}";
    return 1;
  fi

  local app_name app_version link_arg test_arg
  local install_path base_path
  local recipe_name recipe_channel
  local local_bin_path

  local rm_cmd mkdir_cmd;
  rm_cmd="$(which_bin rm)";
  mkdir_cmd="$(which_bin mkdir)";

  local sys_arch sys_kernel_name;
  # e.g.: 'x86_64', 'arm64'
  sys_arch="$(uname -m)";
  # e.g.: 'Linux', 'Darwin'
  sys_kernel_name="$(uname -s)";
  if [[ ${sys_kernel_name} == Darwin ]]; then
    sys_kernel_name='MacOSX';
  fi

  app_name="$1"
  app_version="$2"
  install_path="$3"

  test_arg='--version'
  link_arg=''

  recipe_channel='conda-forge'

  # Choose conda-forge recipe based on app_name
  if [[ -z "${app_name}" ]]; then
    return 1  # exit
  elif [[ "${app_name}" == R ]]; then
    recipe_name='r-base'
  elif [[ "${app_name}" == python ]]; then
    recipe_name='python'
  fi

  # Choose version of the recipe and language
  # TODO luciorq Automatically check latest versions from recipe site,
  # + e.g.: <https://anaconda.org/conda-forge/r-base>
  if [[ -z "${app_version}" ]]; then
    # TODO luciorq replace fixed string with read global option implementation
    # + e.g.: app_version=$(read_option "${_ENV_PREFIX}_${app_name}_version")
    app_version=4.1.3; # R version
  fi

  install_path=$(eval echo "${install_path}")
  if [[ -z "${install_path}" ]]; then
    install_path="${HOME}/.local/opt/mamba"
    # install_path=/opt/langs;
  fi

  if [[ ! -d ${install_path} ]]; then
    "${mkdir_cmd}" -p "${install_path}";
  fi

  install_path=$(eval realpath "${install_path}")
  base_path="${install_path}"/"${app_name}"

  if [[ ! -d ${base_path} ]]; then
    "${mkdir_cmd}" -p "${base_path}";
  fi

  local base_forge_url;
  base_forge_url="https://github.com/conda-forge/miniforge/releases/latest/download";
  base_forge_url="${base_forge_url}/Mambaforge-${sys_kernel_name}-${sys_arch}.sh";

  curl -fsSL \
    -o "${install_path}"/mambaforge.sh \
    "${base_forge_url}";
  chmod 755 "${install_path}"/mambaforge.sh
  "${install_path}"/mambaforge.sh -b -p "${install_path}"/mambaforge;
  "${install_path}"/mambaforge/bin/mamba \
      create \
      --quiet --yes \
      --prefix "${base_path}"/"${app_version}" \
      --channel "${recipe_channel}" \
      "${recipe_name}"="${app_version}";

  # test if installed version is working
  "${base_path}"/"${app_version}"/bin/"${app_name}" "${test_arg}"

  # upgrade Language specific tools
  if [[ ${app_name} == python ]]; then
    # pip and build tools for python
    "${base_path}"/"${app_version}"/bin/pip install --upgrade \
      pip \
      setuptools \
      wheel
  elif [[ ${app_name} == R ]]; then
    # TODO luciorq Install system libraries that R packages depend on
    # Convert system libraries from 'ubuntu' to 'conda-forge'
    # + Check 'sysreqs' R package
    #local r_bin
    #r_bin="$(which R)"
    "${install_path}"/mambaforge/bin/mamba \
      install \
      --quiet --yes \
      --prefix "${base_path}"/"${app_version}" \
      --channel "${recipe_channel}" \
      r-curl;
    # "${r_bin}" -s -q -e "install.packages(c('remotes','renv','pak'))"
  fi

 if [[ ! "$4" == "" ]]; then
    link_arg="$4"
    if [[ "${link_arg}" == link=true ]]; then
      function query_string () {
        local path_content regex_to_search
        # TODO luciorq Add more testing to the PATH checking
        path_content="${PATH}"
        regex_to_search="\s+.*${HOME}/\.local/bin[^/].*\s+"
        if [[ ! " ${path_content} " =~ ${regex_to_search} ]]; then
          "${mkdir_cmd}" -p "${HOME}"/.local/bin
          . "${HOME}"/.profile
        fi
      }

      # check if xdg spec variables are set
      if [[ -z "${XDG_BIN_HOME}" ]]; then
        local_bin_path="${HOME}"/.local/bin
      else
        local_bin_path="${XDG_BIN_HOME}"
      fi

      if [[ ! -d ${local_bin_path} ]]; then
        "${mkdir_cmd}" -p "${local_bin_path}";
      fi

      # Link current version as default and add to local path if necessary
      if [[ -d "${base_path}"/bin ]]; then
        "${rm_cmd}" -rf "${base_path}"/bin
      fi

      # Link versioned to generic dir
      ln -sf "${base_path}"/"${app_version}"/bin "${base_path}"/bin
    fi
  fi

  # remove miniforge debris
  # "${rm_cmd}" -rf "${base_path}"/miniforge
  # "${rm_cmd}" "${base_path}"/miniforge.sh

  echo -ne "${recipe_name} v${app_version} installed successfully\n";
}

function install_python () {
  install_lang python 3.10.2 '${HOME}/.local/apps' link=true
}

function install_rstats () {
  install_lang R 4.1.2 '${HOME}/.local/apps' link=true
}





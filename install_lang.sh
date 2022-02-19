#!/bin/env bash

# Install programming language from conda-forge pre-compiled binaries
function install_lang () {
  local app_usage="Usage:  install_lang <LANG_APP> <VERSION> <INSTALL_PATH> [<link=true>]"
  if [[ "$#" == 0 || "$1" == -h || "$1" == --help ]]; then
    echo "${app_usage}" 1>&2;
    return 1;
  fi

  local app_name app_version link_arg test_arg
  local install_path base_path
  local arch_var os_var
  local recipe_name recipe_channel
  local local_bin_path

  # 'x86_64' & 'Linux'
  arch_var=$(uname -m)
  os_var=$(uname)

  app_name="$1"
  app_version="$2"
  install_path="$3"

  test_arg='--version'
  link_arg=''

  recipe_channel='conda-forge'

  # Choose conda-forge recipe based on app_name
  if [[ ${app_name} == '' ]]; then
    return 1  # exit
  elif [[ ${app_name} == R ]]; then
    recipe_name='r-base'
  elif [[ ${app_name} == python ]]; then
    recipe_name='python'
  fi

  # Choose version of the recipe and language
  # TODO luciorq Automatically check latest versions from recipe site,
  # + e.g.: <https://anaconda.org/conda-forge/r-base>
  if [[ "${app_version}" == "" ]]; then
    # TODO luciorq replace fixed string with read global option implementation
    # + e.g.: app_version=$(read_option "${_ENV_PREFIX}_${app_name}_version")
    app_version=4.1.2; # R version
  fi

  install_path=$(eval echo "${install_path}")

  if [[ "${install_path}" == "" ]]; then
    install_path=/opt/langs
  fi

  if [[ ! -d ${install_path} ]]; then
    mkdir -p "${install_path}";
  fi

  install_path=$(eval realpath "${install_path}")
  base_path="${install_path}"/"${app_name}"

  if [[ ! -d ${base_path} ]]; then
    mkdir -p "${base_path}";
  fi

  curl -fsSL \
    -o "${base_path}"/miniforge.sh \
    https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-"${os_var}"-"${arch_var}".sh
  chmod 755 "${base_path}"/miniforge.sh
  "${base_path}"/miniforge.sh -b -p "${base_path}"/miniforge
  "${base_path}"/miniforge/bin/conda create --quiet --yes \
      --prefix "${base_path}"/"${app_version}" \
      --channel "${recipe_channel}" \
      "${recipe_name}"="${app_version}"

  # test if installed version is working
  "${base_path}"/"${app_version}"/bin/"${app_name}" "${test_arg}"

  # upgrade Language specific tools
  if [[ ${app_name} == python ]]; then
    # pip and build tools for python
    "${base_path}"/"${app_version}"/bin/pip install --upgrade \
      pip \
      setuptools \
      wheel
  fi

 if [[ ! "$4" == "" ]]; then
    link_arg="$4"
    if [[ "${link_arg}" == link=true ]]; then
      function query_string () {
        local path_content regex_to_search
        path_content="${PATH}"
        regex_to_search="\s+.*${HOME}/\.local/bin[^/].*\s+"
        if [[ ! " ${path_content} " =~ ${regex_to_search} ]]; then
          mkdir -p "${HOME}"/.local/bin
	  . "${HOME}"/.profile
        fi
      }

      if [[ ! "$(cat ${HOME}/.profile)" =~ \$HOME/\.local/bin ]]; then
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "${HOME}"/.profile;
	. "${HOME}"/.profile;
      fi

      if [[ ! "$(cat ${HOME}/.profile)" =~ export\ PATH=\"\$HOME/\.local/bin.*\" ]]; then
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "${HOME}"/.profile;
	. "${HOME}"/.profile;
      fi

      # check if xdg spec variables are set
      if [[ -z "${XDG_BIN_HOME}" ]]; then
        local_bin_path="${HOME}"/.local/bin
      else
        local_bin_path="${XDG_BIN_HOME}"
      fi

      if [[ ! -d ${local_bin_path} ]]; then
        mkdir -p "${local_bin_path}";
      fi

      # Link current version as default and add to local path if necessary
      ln -sf "${base_path}"/"${app_version}"/bin "${base_path}"/bin
      ln -sf "${base_path}"/bin/"${app_name}" "${local_bin_path}"/"${app_name}"
    fi
  fi

  # remove miniforge debris
  local rm_cmd
  rm_cmd=$(which -a rm | head -1)
  "${rm_cmd}" -rf "${base_path}"/miniforge
  "${rm_cmd}" "${base_path}"/miniforge.sh

  echo "${recipe_name} v${app_version} installed successfully"
}

# install_lang R 4.1.2 '${HOME}/.local/apps' link=true
# install_lang python 3.10.2 '${HOME}/.local/apps' link=true


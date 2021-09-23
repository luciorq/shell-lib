#!/usr/bin/env bash
# Install R-base from conda-forge pre-compiled binaries
function install_rstats () {
  local usage="install_rstats <VERSION> <INSTALL_PATH> [<link=true>]"
  local app_version link_arg
  local install_path base_path
  # local exec_links i
  app_version="$1"
  install_path="$2"
  link_arg=''
  if [[ "${app_version}" == "" ]]; then
    # TODO luciorq replace fixed string read global option
    # app_version=$(read_option "${ENV_PREFIX}_rstats_version")
    app_version=4.1.1
  fi
  if [[ "${install_path}" == "" ]]; then
    install_path=/opt/apps
  fi
  install_path=$(eval realpath "${install_path}")
  base_path="${install_path}"/R

  mkdir -p "${base_path}"

  curl -fsSL \
    -o "${base_path}"/miniconda.sh \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
  chmod 755 "${base_path}"/miniconda.sh
  "${base_path}"/miniconda.sh -b -p "${base_path}"/miniconda
  "${base_path}"/miniconda/bin/conda create --quiet --yes \
      --prefix "${base_path}"/"${app_version}" \
      --channel conda-forge \
      r-base="${app_version}"

  # test
  "${base_path}"/"${app_version}"/bin/R --version

  ln -sf "${base_path}"/"${app_version}"/bin "${base_path}"/bin

  if [[ ! "$3" == "" ]]; then
    link_arg="$3"
    if [[ "${link_arg}" == link=true ]]; then
      local new_path_str
      new_path_str="export PATH=${base_path}"/bin'${PATH:+:${PATH}}'
      echo "${new_path_str}" >> "${HOME}/.profile"
    fi
  fi

  rm -rf "${base_path}"/miniconda
  rm "${base_path}"/miniconda.sh
  echo "R-base v${app_version} installed successfully"
}

install_rstats 4.1.1 '${HOME}/.local/apps' link=true

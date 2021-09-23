#!/usr/bin/env bash
# Install Python from pre-compiled binaries
function install_python () {
  local usage="install_python <VERSION> <INSTALL_PATH> [<link=true>]"
  local python_version link_arg
  local install_path base_path
  local arch_var os_var
  # TODO luciorq add variable device architecture
  # device_arch='x86_64'
  arch_var=$(uname -m)
  os_var=$(uname)

  python_version="$1"
  install_path="$2"
  link_arg=''
  if [[ "${python_version}" == "" ]]; then
    # TODO luciorq replace fixed string read global option
    # python_version=$(read_option "${ENV_PREFIX}_python_version")
    python_version=3.9.7
  fi
  if [[ "${install_path}" == "" ]]; then
    install_path=/opt
  fi
  install_path=$(eval realpath "${install_path}")
  base_path="${install_path}"/python

  mkdir -p "${base_path}"

  # TODO luciorq replacing miniconda to miniforge
  curl -fsSL \
    -o "${base_path}"/miniforge.sh \
    https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-"${os_var}"-"${arch_var}".sh
  chmod 755 "${base_path}"/miniforge.sh
  "${base_path}"/miniforge.sh -b -p "${base_path}"/miniforge
  "${base_path}"/miniforge/bin/conda create --quiet --yes \
      --prefix "${base_path}"/"${python_version}" \
      --channel conda-forge \
      python="${python_version}"
  # For python2 "pip<20.1" is necessary as last argument

  # test
  "${base_path}"/"${python_version}"/bin/python --version

  # upgrade pip and build tools
  "${base_path}"/"${python_version}"/bin/pip install --upgrade \
    pip setuptools wheel

  ln -sf "${base_path}"/"${python_version}"/bin "${base_path}"/bin

  if [[ ! "$3" == "" ]]; then
    link_arg="$3"
    if [[ "${link_arg}" == link=true ]]; then
      local new_path_str
      new_path_str="export PATH=${base_path}"/bin'${PATH:+:${PATH}}'
      echo "${new_path_str}" >> "${HOME}/.profile"
    fi
  fi

  rm -rf "${base_path}"/miniforge
  rm "${base_path}"/miniforge.sh
  echo "Python v${python_version} installed successfully"
}

install_python 3.9.7 '${HOME}/.local/apps' link=true

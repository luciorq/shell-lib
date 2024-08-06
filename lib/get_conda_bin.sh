#!/usr/bin/env bash

# Return conda executable based on preference
function get_conda_bin () {
  builtin local conda_bin;
  conda_bin="$(which_bin 'micromamba')";
  if [[ -z ${conda_bin} ]]; then
    conda_bin="$(which_bin 'mamba')";
  fi
  if [[ -z ${conda_bin} ]]; then
    conda_bin="$(which_bin 'conda')";
  fi
  # if [[ -z ${conda_bin} ]] && \
  #   [[ "$(LC_ALL=C builtin type -t '__install_app')" =~ function ]]; then
  #   __install_app 'micromamba';
  #   conda_bin="$(which_bin 'micromamba')";
  # fi
  if [[ -z ${conda_bin} ]]; then
    install_micromamba --force;
    conda_bin="$(which_bin 'micromamba')";
  fi
  if [[ -z ${conda_bin} ]]; then
    exit_fun '`conda`, `mamba`, and `micromamba` are not available for this system';
    builtin return 1;
  fi
  builtin echo -ne "${conda_bin}";
  builtin return 0;
}

function conda_priv_fun () {
  local conda_bin;
  local env_name;
  local conda_env_exports;
  conda_bin="$(get_conda_bin)";
  if [[ ${1:-} =~ activate ]]; then
    env_name="${2-}";
    if [[ "${conda_bin}" =~ micromamba$ ]]; then
      conda_env_exports="$("${conda_bin}" shell "${env_name}" activate --shell bash)";
    else
      conda_env_exports="$("${conda_bin}" shell.posix activate "${env_name}")";
    fi
    builtin eval "${conda_env_exports}";
    builtin hash -r;
    builtin return 0;
  fi
  "${conda_bin}" "${@:-}";
  builtin return 0;
}

# Platform independent installation of micromamba
# + respecting xdg basedir spec
function install_micromamba () {
  builtin local _usage="Usage: ${0} [--force] [--system]";
  builtin unset _usage;
  builtin local micromamba_bin;
  builtin local conda_platform;
  builtin local download_url;
  builtin local _arg;
  builtin local install_type;
  builtin local force_flag;
  builtin local inst_path;
  builtin local link_path;
  builtin local link_dir;
  builtin local dl_path;
  builtin local chmod_bin;
  builtin local ln_bin;
  builtin local rm_bin;
  builtin local mkdir_bin;

  # TODO(luciorq): check if micromamba is already installed for the root user
  # + when `--system`` flag is provided.
  force_flag='0';
  for _arg in "${@}"; do
    if [[ ${_arg} == --force ]]; then
      force_flag='1';
    fi
  done
  micromamba_bin="$(which_bin 'micromamba')";
  if [[ -n ${micromamba_bin} ]] && [[ ${force_flag} == '0' ]]; then
    \builtin echo -ne "\`micromamba\` already installed at \`${micromamba_bin}\`";
    \builtin return 0;
  fi

  chmod_bin="$(which_bin 'chmod')";
  ln_bin="$(which_bin 'ln')";
  rm_bin="$(which_bin 'rm')";
  mkdir_bin="$(which_bin 'mkdir')";

  conda_platform="$(get_conda_platform)";
  download_url="https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-${conda_platform}";

  inst_path="${HOME}/.local/opt/apps/micromamba";
  link_path="${HOME}/.local/bin/micromamba";
  dl_path="${inst_path}/micromamba-${conda_platform}";
  # builtin local install_type;
  for _arg in "${@}"; do
    if [[ ${_arg} == --system ]]; then
      install_type="system";
    fi
  done

  if [[ ${install_type} == system ]]; then
    inst_path="/opt/apps/micromamba";
    link_path="/usr/local/bin/micromamba";
    dl_path="/tmp/micromamba-${conda_platform}";
  fi

  # Remove installed paths if `--force` flag is provided
  if [[ ${force_flag} == '1' ]]; then
    if [[ -d "${inst_path}" ]]; then
      "${rm_bin}" -rf "${inst_path}";
    fi
    if [[ -f "${link_path}" ]]; then
      "${rm_bin}" -f "${link_path}";
    fi
  fi

  if [[ -f ${dl_path} ]]; then
    "${rm_bin}" -f "${dl_path}";
  fi
  download "${download_url}" "${inst_path}";
  "${chmod_bin}" +x "${dl_path}";
  link_dir="$(dirname_pure "${link_path}")";
  if [[ ! -d ${link_dir} ]]; then
    "${mkdir_bin}" -p "${link_dir}";
  fi
  "${ln_bin}" -sf "${dl_path}" "${link_path}";
  \builtin return 0;
}

# Retrive conda native platform in the form of `os-arch`
function get_conda_platform () {
  \builtin local os_type;
  \builtin local os_arch;
  \builtin local platform_str;

  os_type="$(get_os_type)";
  os_arch="$(get_os_arch)";

  case "${os_type}" in
    linux)
      os_type="linux" ;;
    darwin)
      os_type="osx" ;;
    *nt*)
      os_type="win" ;;
  esac

  case "${os_arch}" in
    aarch64|ppc64le|arm64)
      ;;  # pass
    *)
      os_arch="64" ;;
  esac

  platform_str="${os_type}-${os_arch}";

  case "${platform_str}" in
    osx-aarch64)
      platform_str="osx-arm64" ;;
    *)
      ;;  # pass
  esac
  case "${platform_str}" in
    linux-aarch64|linux-ppc64le|linux-64|osx-arm64|osx-64|win-64)
      ;;  # pass
    *)
      exit_fun 'get_conda_platform: Failed to detect supported OS';
      \builtin return 1;
      ;;
  esac

  \builtin echo -ne "${platform_str}";
  \builtin return 0;
}

# This function just works on MacOS
function __conda_platform_arm64_to_64 () {
  \builtin local platform_str;
  platform_str=$(get_conda_platform);
  if [[ "${platform_str}" =~ osx-arm64 ]]; then
    \builtin echo -ne 'osx-64';
  else
    \builtin echo -ne "${platform_str}";
  fi
  \builtin return 0;
}

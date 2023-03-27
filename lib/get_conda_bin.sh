#!/usr/bin/env bash

# Return conda executable based on preference
function get_conda_bin () {
  local conda_bin;
  conda_bin="$(which_bin 'micromamba')";
  if [[ -z ${conda_bin} ]]; then
    conda_bin="$(which_bin 'mamba')";
  fi
  if [[ -z ${conda_bin} ]]; then
    conda_bin="$(which_bin 'conda')";
  fi
  if [[ -z ${conda_bin} ]] && \
    [[ "$(LC_ALL=C builtin type -t '__install_app')" =~ function ]]; then
    __install_app 'micromamba';
    conda_bin="$(which_bin 'micromamba')";
  fi
  if [[ -z ${conda_bin} ]]; then
    exit_fun 'conda, mamba, and micromamba are not available for this system';
    return 1;
  fi
  builtin echo -ne "${conda_bin}";
  return 0;
}

function conda_priv_fun () {
  local conda_bin;
  local env_name;
  local conda_env_exports;
  conda_bin="$(get_conda_bin)";
  if [[ ${1} =~ activate ]]; then
    env_name="${2-}";
    if [[ "${conda_bin}" =~ micromamba$ ]]; then
      conda_env_exports="$("${conda_bin}" shell --shell bash activate "${env_name}")";
    else
      conda_env_exports="$("${conda_bin}" shell.posix activate "${env_name}")";
    fi
    builtin eval "${conda_env_exports}";
    builtin hash -r;
    builtin return 0;
  fi
  "${conda_bin}" "${@}";
  builtin return 0;
}
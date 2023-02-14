#!/usr/bin/env bash

# Return conda executable based on preference
function get_conda_bin () {
  local conda_bin;
  conda_bin="$(which_bin 'mamba')";
  if [[ -z ${conda_bin} ]]; then
    conda_bin="$(which_bin 'micromamba')";
  fi
  if [[ -z ${conda_bin} ]]; then
    conda_bin="$(which_bin 'conda')";
  fi
  if [[ -z ${conda_bin} ]] && \
    [[ "$(LC_ALL=C builtin type -t '__install_app')" =~ function ]]; then
    __install_app 'mamba';
    conda_bin="$(which_bin 'mamba')";
  fi
  if [[ -z ${conda_bin} ]]; then
    exit_fun 'Conda is not available for this system';
    return 1;
  fi
  builtin echo -ne "${conda_bin}";
  return 0;
}
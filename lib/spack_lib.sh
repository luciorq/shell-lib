#!/usr/bin/env bash

# Load Spack environment for BASH
# + from: https://spack.readthedocs.io/en/latest/getting_started.html
function spack_load_env () {
  local spack_dir;
  # Load Spack environment
  spack_dir="${1:-${SPACK_ROOT}}";

  if [[ -z ${spack_dir} ]]; then
    # for WCM SCU path
    spack_dir="/opt/spack";
    if [[ ! -d ${spack_dir} ]]; then
      spack_dir="/software/spack";
    fi
  fi
  if [[ -n ${spack_dir} ]]; then
    if [[ -f "${spack_dir}/share/spack/setup-env.sh" ]]; then
      builtin source "${spack_dir}/share/spack/setup-env.sh";
    fi
  fi
  return 0;
}
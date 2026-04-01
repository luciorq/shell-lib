#!/usr/bin/env bash

# Load Spack environment for BASH
# + from: https://spack.readthedocs.io/en/latest/getting_started.html
function spack_load_env () {
  \builtin local _usage;
  _usage='Usage: spack_load_env [SPACK_DIR]';
  \builtin unset -v _usage;
  \builtin local spack_dir;

  # check for environment variable first, then argument, then default paths
  spack_dir="${1:-${SPACK_ROOT:-}}";

  if [[ -z ${spack_dir} ]]; then
    # for WCM SCU path
    spack_dir="/opt/spack";
    if [[ ! -d ${spack_dir} ]]; then
      spack_dir="/software/spack";
    fi
  fi

  # Load Spack environment
  if [[ -n ${spack_dir} ]]; then
    if [[ -f "${spack_dir}/share/spack/setup-env.sh" ]]; then
      \builtin source "${spack_dir}/share/spack/setup-env.sh";
    fi
  fi
  \builtin return 0;
}
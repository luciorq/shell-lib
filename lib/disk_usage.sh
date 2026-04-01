#!/usr/bin/env bash

function disk_usage () {
  \builtin local iostat_bin;
  \builtin local nfsiostat_bin;
  \builtin local zpool_bin;

  # Run dfh function if available
  if \builtin type -t dfh &>/dev/null; then
    dfh;
  fi

  iostat_bin="$(which_bin 'iostat')";
  nfsiostat_bin="$(which_bin 'nfsiostat')";
  zpool_bin="$(which_bin 'zpool')";

  if [[ -n ${iostat_bin} ]]; then
    if [[ $(get_os_type) == darwin ]]; then
      "${iostat_bin}";
    else
      "${iostat_bin}" -x -h;
    fi
  fi
  if [[ -n ${nfsiostat_bin} ]]; then
    "${nfsiostat_bin}";
  fi
  if [[ -n ${zpool_bin} ]]; then
    "${zpool_bin}" iostat;
  fi
  \builtin return 0;
}

#!/usr/bin/env bash

function disk_usage () {
  local iostat_bin;
  local nfsiostat_bin;
  local zpool_bin;
  dfh;
  iostat_bin="$(which_bin 'iostat')"
  nfsiostat_bin="$(which_bin 'nfsiostat')"
  zpool_bin="$(which_bin 'zpool')"
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
  return 0;
}

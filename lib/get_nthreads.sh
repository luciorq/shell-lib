#!/usr/bin/env bash

# Try to set a reasonable ammount of CPUs for compiling tasks
# + default behavior is to use a maximum of 8 threads, if it is not the
# + half of all available threads;
# @param $1 maximum allowed number of threads; Default: 8;
# @return number of threads available to be used;
function get_nthreads () {
  local nproc_bin;
  local lscpu_bin;
  local grep_bin;
  local num_threads;
  local half_threads;
  local max_threads_to_use;
  local threads_to_use;
  max_threads_to_use="${1:-8}";
  nproc_bin="$(which_bin 'nproc')";
  lscpu_bin="$(which_bin 'lscpu')";
  grep_bin="$(require 'grep')";
  if [[ -n ${nproc_bin} ]]; then
    num_threads="$("${nproc_bin}")";
  elif [[ -e /proc/cpuinfo ]]; then
    num_threads="$("${grep_bin}" -c 'processor' '/proc/cpuinfo')";
  elif [[ -n ${lscpu_bin} ]]; then
    num_threads="$("${lscpu_bin}" | "${grep_bin}" '^CPU(' | awk '{print $2}')";
  else
    builtin echo -ne "4";
    return 0;
  fi

  half_threads="$((num_threads/2))";

  threads_to_use="${half_threads}";
  if [[ ${threads_to_use} -gt ${max_threads_to_use} ]]; then
    threads_to_use="${max_threads_to_use}";
  fi

  builtin echo -ne "${threads_to_use}";
  return 0;
}

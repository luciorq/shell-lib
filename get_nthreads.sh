#!/usr/bin/env bash

function get_nthreads () {
  local nthreads;


  nthreads=$(nproc);

  "$(grep processor /proc/cpuinfo | tail -n 1 | awk '{print $3}')"
# third try
lscpu | grep "^CPU(" | awk '{print $2}'

  builtin echo -ne "${nthreads}";
  return 0;
}

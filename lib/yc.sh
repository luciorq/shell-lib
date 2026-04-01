#!/usr/bin/env bash

# parse Shell commands into YAML output
function yc () {
  \builtin local jc_bin;
  \builtin local yq_bin;

  jc_bin="$(require 'jc')";
  yq_bin="$(require 'yq')";

  "${jc_bin}" "${@}" \
    | "${yq_bin}" -P;
  \builtin return 0;
}

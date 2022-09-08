#!/usr/bin/env bash

# parse Shell commands into YAML output
function yc () {
  local jc_bin;
  local yq_bin;

  jc_bin="$(require 'jc')";
  yq_bin="$(require 'yq')";

  "${jc_bin}" "${@}" \
    | "${yq_bin}" -P;
  return 0;
}

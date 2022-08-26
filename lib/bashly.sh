#!/usr/bin/env bash
# shellcheck shell=bash

# Install and/or update bashly
function bashly_install () {
  local gem_bin;
  gem_bin="$(which_bin 'gem')";
  "${gem_bin}" install bashly;
  return 0;
}

function bashly_update () {
  bashly_install;
  return 0;
}

# Build BASH script from bashly
function bashly_build () {
  local _usage="Usage: ${0} <BASHLY_FILE>";
  local bashly_bin;
  local _function_name;
  bashly_bin="$(which_bin 'bashly')";

  if [[ -z ${bashly_bin} ]]; then
    exit_fun '{bashly} not found';
    return 1;
  fi;
  "${bashly_bin}" generate \
    --upgrade \
    --env production \
    --wrap "${_function_name}";

  return 0;
}
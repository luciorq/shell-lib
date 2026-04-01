#!/usr/bin/env bash
# shellcheck shell=bash

# Install and/or update bashly
function bashly_install () {
  \builtin local gem_bin;
  gem_bin="$(which_bin 'gem')";
  "${gem_bin}" install bashly;
  \builtin return 0;
}

function bashly_update () {
  bashly_install;
  \builtin return 0;
}

# Build BASH script from bashly
function bashly_build () {
  \builtin local _usage;
  _usage="Usage: ${0} <BASHLY_FILE>";
  \builtin unset -v _usage;
  \builtin local bashly_bin;
  \builtin local _function_name;
  bashly_bin="$(which_bin 'bashly')";

  if [[ -z ${bashly_bin} ]]; then
    exit_fun '{bashly} not found';
    \builtin return 1;
  fi;
  "${bashly_bin}" generate \
    --upgrade \
    --env production \
    --wrap "${_function_name}";

  \builtin return 0;
}
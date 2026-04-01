#!/usr/bin/env bash

# Function to source just recipe in the current shell
function just_source () {
  \builtin local just_bin;
  \builtin local recipe_name;
  just_bin="$(require 'just')";
  recipe_name="${1}";
  if [[ -z ${just_bin} ]]; then
    exit_fun "'just' is not installed.";
    \builtin return 1;
  fi
  if [[ -z ${recipe_name} ]]; then
    "${just_bin}" --list;
  else
    \builtin eval "$("${just_bin}" --dry-run "${recipe_name}" 2>&1)";
  fi
  \builtin return 0;
}
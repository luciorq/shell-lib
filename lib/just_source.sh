#!/usr/bin/env bash

# Function to source just recipe in the current shell
function just_source () {
  local just_bin;
  local recipe_name;
  just_bin="$(require 'just')";
  recipe_name="${1}";
  if [[ -z ${just_bin} ]]; then
    exit_fun "'just' is not installed.";
    return 1;
  fi
  if [[ -z ${recipe_name} ]]; then
    "${just_bin}" --list;
  else
    builtin eval "$("${just_bin}" --dry-run "${recipe_name}" 2>&1)";
  fi
  return 0;
}
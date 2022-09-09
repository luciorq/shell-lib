#!/usr/bin/env bash

# Remove file from git history
# + and sync remote
function git_remove_file () {
  local file_to_remove;
  local git_bin;
  local realpath_bin;
  local git_remove_cmd;
  file_to_remove="${1}";
  if [[ -z ${file_to_remove} ]]; then
    exit_fun "'${file_to_remove}' is not found.";
  fi
  git_bin="$(require 'git')";
  realpath_bin="$(require 'realpath')";
  git_remove_cmd="git rm -rf --cached --ignore-unmatch";
  FILTER_BRANCH_SQUELCH_WARNING=1 "${git_bin}" \
    filter-branch --index-filter \
    "${git_remove_cmd} '$("${realpath_bin}" "${file_to_remove}")'" \
    HEAD;
  "${git_bin}" push --force --all;
  return 0;
}

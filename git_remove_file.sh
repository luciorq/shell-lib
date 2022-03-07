#!/usr/bin/env bash

# Remove file from git history
# + and sync remote
function git_remove_file () {
  local file_to_remove git_bin;
  git_bin="$(check_installed 'git')";
  file_to_remove="$1";


  FILTER_BRANCH_SQUELCH_WARNING=1 "${git_bin}" \
    filter-branch --index-filter \
    'git rm -rf --cached --ignore-unmatch "$(realpath ${file_to_remove})"' HEAD;

  "${git_bin}" push --force --all;
}

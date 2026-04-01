#!/usr/bin/env bash

# Remove file from git history
# + and sync remote
function git_remove_file () {
  \builtin local file_to_remove;
  \builtin local git_bin;
  \builtin local git_remove_cmd;
  file_to_remove="${1:-}";
  if [[ -z "${file_to_remove}" ]]; then
    exit_fun "'${file_to_remove}' is not found.";
  fi
  git_bin="$(require 'git')";
  git_remove_cmd="git rm -rf --cached --ignore-unmatch";
  FILTER_BRANCH_SQUELCH_WARNING=1 "${git_bin}" \
    filter-branch --index-filter \
    "${git_remove_cmd} '${file_to_remove}'" \
    HEAD;

  # confirm before pushing to remote
  \builtin read -r -p "Are you sure you want to push the changes to remote? [y/N] " confirm_push;
  if [[ ! "${confirm_push,,}" =~ ^(yes|y)$ ]]; then
    \builtin echo -ne "Aborting push to remote.\n";
    \builtin return 0;
  fi
  "${git_bin}" push --force --all;
  \builtin return 0;
}

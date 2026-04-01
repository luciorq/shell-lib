#!/usr/bin/env bash

# TODO: @luciorq - Implement this function
function replace_in_file () {
  \builtin local replace_str;
  \builtin local search_regex;
  \builtin local file_path;
  \builtin local sed_bin;
  \builtin local grep_bin;
  search_regex="${1:-}";
  replace_str="${2:-}";
  file_path="${3:-}";
  sed_bin="$(require 'sed')";
  grep_bin="$(require 'grep')";

  if [[ -z "${search_regex}" || -z "${replace_str}" || -z "${file_path}" ]]; then
    exit_fun "Usage: replace_in_file <search_regex> <replace_str> <file_path>";
    \builtin return 1;
  fi

  \builtin echo "Replacing '${search_regex}' with '${replace_str}' in file '${file_path}'";

  "${sed_bin}" -i '' "s/${search_regex}/${replace_str}/g" "${file_path}";

  # Check if it really replaced the string, if not, print a warning.
  if ! "${grep_bin}" -q "${replace_str}" "${file_path}"; then
    exit_fun "Warning: '${replace_str}' not found in '${file_path}' after replacement.";
    \builtin return 1;
  fi

  # sed -i '' '1 aauth sufficient pam_tid.so' /etc/pam.d/sudo
  # sed -i '' '1 a\

  \builtin return 0;
}

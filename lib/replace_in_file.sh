#!/usr/bin/env bash

# TODO luciorq
function replace_in_file () {
  local replace_str;
  local search_regex;
  local file_path;
  local sed_bin;
  search_regex="$1";
  replace_str="$2";
  file_path="$3";
  sed_bin="$(require 'sed')";

  # sed -i '' '1 aauth sufficient pam_tid.so' /etc/pam.d/sudo
  # sed -i '' '1 a\
  return 0;
}

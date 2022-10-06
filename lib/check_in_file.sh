#!/usr/bin/env bash

# Check if text is present in file
# TODO: @luciorq finish implementing check string in file
# TODO: @luciorq Implement find and replace, based on check in file
function check_in_file () {
  local str_to_search;
  local file_to_search;
  local search_res;
  local grep_bin;
  grep_bin="$(require 'grep')";
  str_to_search="$1";
  file_to_search="$2";

  if [[ -z ${str_to_search} ]]; then
    builtin echo >&2 -ne "Invalid execution.\n";
    return 1;
  fi

  if [[ ! -f ${file_to_search} ]]; then
    builtin echo >&2 -ne "[${file_to_search}] does not exist.\n";
    return 1;
  fi

  # Check presence of str_to_search in file
  search_res=$("${grep_bin}" "${str_to_search}" "${file_to_search}")

  if [[ -n ${search_res[@]} ]]; then
    builtin echo -ne 'true';
  else
    builtin echo -ne 'false';
  fi
  return 0;
}

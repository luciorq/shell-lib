#!/usr/bin/env bash

# TODO: @luciorq This is probably leftover from a distant past, should be removed?
# This function will return the path of a command, if it exists in the system.
function type_str () {
  \builtin local type_key;
  \builtin local type_str_arr;
  type_key="${1:-}";

  # Using associative array to map type keys to their corresponding strings
  \builtin declare -A type_str_arr;
  type_str_arr=(
    [keyword]="is a shell keyword"
    [builtin]="is a shell builtin"
    [alias]="is aliased to"
    [function]="is a function"
  )

  \builtin echo "${type_str_arr["${type_key}"]}";
  \builtin return 0;
}

function remove_line () {
    \builtin local input_str;
    \builtin local type_key;

    \builtin local grep_bin;
    grep_bin="$(require 'grep')";

    input_str="${1:-}";
    type_key="${2:-}";
    \builtin echo "${input_str}" \
      | "${grep_bin}" -v "$(type_str "${type_key}")";
    \builtin return 0;
}

function command_path () {
  \builtin local cmd_str;
  \builtin local cmd_bin;
  \builtin local type_text;
  cmd_str="${1:-}";
  cmd_bin="$(which_bin "${cmd_str}")";
  if [[ -z ${cmd_bin} ]]; then
    \builtin echo >&2 -ne "'${cmd_str}' executable not found in '\${PATH}'\n";
    \builtin return 1;
  fi
  type_text=$(\builtin type -a "${cmd_str}" 2> /dev/null | grep -i ".* is .*")

  \builtin echo -ne 'Debug 1\n';
  \builtin echo "${type_text}";


  for type_key in 'keyword' 'builtin' 'alias' 'function'; do
    type_text="$(remove_line "${type_text}" "${type_key}")";
  done

  \builtin echo -ne 'Debug 2\n';
  \builtin echo "${type_text}";

  \builtin return 0;
}

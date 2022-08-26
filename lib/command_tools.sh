#!/usr/bin/env bash

function type_str () {
  local type_key type_str_arr;
  type_key="$1"

  declare -A type_str_arr=(
    [keyword]="is a shell keyword"
    [builtin]="is a shell builtin"
    [alias]="is aliased to"
    [function]="is a function"
  )
  echo "${type_str_arr["${type_key}"]}";
  return 0;
}

function remove_line () {
    local input_str type_key;
    input_str="$1"
    type_key="$2"
    echo "${input_str}" \
      | grep -v "$(type_str "${type_key}")";
    return 0;
}

function command_path () {
  local cmd_str cmd_bin type_text;
  cmd_str="$1"
  type_text=$(type -a "${cmd_str}" 2> /dev/null | grep -i ".* is .*")

  echo "Debug 1"
  echo $type_text


  for type_key in "keyword builtin alias function"; do
    type_text="$(remove_line "${type_text}" "${type_key}")";
  done

  echo "Debug 2"
  echo "${type_text}"
}

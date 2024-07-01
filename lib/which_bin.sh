#!/usr/bin/env bash

# Return the first executable on path
function which_bin() {
  \builtin local cmd_arg
  \builtin local path_dir_arr
  \builtin local path_dir
  \builtin local file_name
  \builtin local cmd_bin
  cmd_arg="${1:-}"
  cmd_bin=''
  IFS=: \builtin read -r -a path_dir_arr <<<"${PATH:-}"
  for path_dir in "${path_dir_arr[@]}"; do
    file_name="${path_dir}/${cmd_arg}"
    if [[ -x "${file_name}" && ! -d "${file_name}" ]] && [[ "${file_name}" =~ ${cmd_arg}$ ]]; then
      cmd_bin="${file_name}"
      \builtin break
    fi
  done
  \builtin echo -ne "${cmd_bin}"
  \builtin return 0
}

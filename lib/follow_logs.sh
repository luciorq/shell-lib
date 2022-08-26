#!/usr/bin/env bash

# Follow logs with color syntax
function follow_logs () {
  local file_path;
  local tail_bin;
  local bat_bin;
  builtin mapfile -t file_path < <( "${@}" );
  tail_bin=$(which_bin 'tail');
  bat_bin=$(which_bin 'bat');
  "${tail_bin}" -f "${file_path[@]}" \
    | "${bat_bin}" --paging=never -l log -p;
  return 0;
}

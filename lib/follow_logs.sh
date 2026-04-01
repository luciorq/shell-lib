#!/usr/bin/env bash

# Follow logs with color syntax
function follow_logs () {
  \builtin local file_path;
  \builtin local tail_bin;
  \builtin local bat_bin;
  \builtin mapfile -t file_path < <( "${@}" );
  tail_bin=$(which_bin 'tail');
  bat_bin=$(which_bin 'bat');
  "${tail_bin}" -f "${file_path[@]}" \
    | "${bat_bin}" --paging=never -l log -p;
  \builtin return 0;
}

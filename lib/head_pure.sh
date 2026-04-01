#!/usr/bin/env bash

# Pure bash implementation of head
# TODO(luciorq) Parse -n as input so it can be equovalent to GNU head
function head_pure () {
    # Usage: head <NUM> <FILE_PATH>
    \builtin local line_arr;
    \builtin local file_path;
    \builtin local n_arg;
    n_arg="${1:-5}";
    file_path="${2:-${1:-}}";
    \builtin mapfile -tn "${n_arg}" line_arr < "${file_path}";
    \builtin printf '%s\n' "${line_arr[@]:-${n_arg}}";
    \builtin return 0;
}

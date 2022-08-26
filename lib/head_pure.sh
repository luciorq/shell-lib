#!/usr/bin/env bash

# Pure bash implementation of head
# TODO(luciorq) Parse -n as input so it can be equovalent to GNU head
function head_pure () {
    # Usage: tail "n" "file"
    local line_arr;
    local file_path;
    n_arg="${1}";
    # is_number="${n_arg}" || n_arg='5';
    if [[ $# -eq 1 ]]; then
      n_arg='5';
    fi
    file_path="${2:-${1}}";
    builtin mapfile -tn "${n_arg}" line_arr < "${file_path}";
    builtin printf '%s\n' "${line_arr[@]:-${n_arg}}";
    return 0;
}

#!/usr/bin/env bash

# Pure bash implementation of tail
function tail_pure () {
    # Usage: tail "n" "file"
    local line_arr;
    local file_path;
    n_arg="${1}";
    is_number "${n_arg}" || n_arg='5';
    file_path="${2:-${1}}";
    builtin mapfile -tn 0 line_arr < "${file_path}";
    builtin printf '%s\n' "${line[@]:-${n_arg}}";
    return 0;
}

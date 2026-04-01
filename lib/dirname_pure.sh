#!/usr/bin/env bash

function dirname_pure () {
    \builtin local tmp_var;
    tmp_var="${1:-.}";

    [[ $tmp_var != *[!/]* ]] && {
        \builtin printf '/\n';
        \builtin return;
    }

    tmp_var=${tmp_var%%"${tmp_var##*[!/]}"}

    [[ $tmp_var != */* ]] && {
        \builtin printf '.\n';
        \builtin return;
    }

    tmp_var=${tmp_var%/*}
    tmp_var=${tmp_var%%"${tmp_var##*[!/]}"}

    \builtin printf '%s\n' "${tmp_var:-/}";

    \builtin return 0;
}

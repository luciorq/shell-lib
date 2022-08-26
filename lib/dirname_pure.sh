#!/usr/bin/env bash

function dirname_pure () {
    local tmp=${1:-.}

    [[ $tmp != *[!/]* ]] && {
        builtin printf '/\n'
        builtin return
    }

    tmp=${tmp%%"${tmp##*[!/]}"}

    [[ $tmp != */* ]] && {
        builtin printf '.\n'
        builtin return;
    }

    tmp=${tmp%/*}
    tmp=${tmp%%"${tmp##*[!/]}"}

    printf '%s\n' "${tmp:-/}"
}

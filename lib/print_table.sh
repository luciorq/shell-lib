#!/usr/bin/env bash

function print_table () {
  \builtin local rich_bin;
  \builtin local cat_bin;

  rich_bin="$(which_bin 'rich')";
  cat_bin="$(require 'cat')";

  if [[ -z "${rich_bin}" ]]; then
    "${cat_bin}" "${@}";
    \builtin return;
  fi
  "${cat_bin}" "${@}" | "${rich_bin}" --csv - ;
  \builtin return 0;
}

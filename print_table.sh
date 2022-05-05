#!/usr/bin/env bash

function print_table () {
  local rich_bin;

  rich_bin="$(which_bin 'rich')";

  if [[ -z ${rich_bin} ]]; then
    cat "${@}";
    return;
  fi
  cat "${@}" | "${rich_bin}" --csv - ;
  return 0;
}

#!/usr/bin/env bash

function __update_configs () {
  \builtin local tldr_bin;
  \builtin local bat_bin;
  tldr_bin="$(which_bin 'tldr')";
  bat_bin="$(which_bin 'bat')";
  if [[ -n ${tldr_bin} ]]; then
    "${tldr_bin}" --update;
  fi
  if [[ -n ${bat_bin} ]]; then
    "${bat_bin}" cache --build;
  fi
  \builtin return 0;
}

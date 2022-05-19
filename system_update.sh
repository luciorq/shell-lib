#!/usr/bin/env bash

function __update_configs () {
  local tldr_bin;
  local bat_bin;
  tldr_bin="$(which_bin 'tldr')";
  bat_bin="$(which_bin 'bat')";
  if [[ -n ${tldr_bin} ]]; then
    "${tldr_bin}" --update;
  fi
  if [[ -n ${bat_bin} ]]; then
    "${bat_bin}" cache --build;
  fi

}

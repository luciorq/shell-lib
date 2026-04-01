#!/usr/bin/env bash

function watch_fun () {
  \builtin local bash_bin;
  \builtin local sleep_time;

  bash_bin="$(require 'bash')";
  sleep_time="2";

  if [[ ! ${sleep_time} =~ \.. ]]; then
    sleep_time="${sleep_time}.0";
  fi

  while true; do
    clear_pure;
    # TODO: @luciorq Add 'date' output to the right side of header
    # + in the following format: Thu May 19 15:01:05 2022;
    \builtin echo -ne "Every ${sleep_time}s: ${*}\n\n";
    "${bash_bin}" \
      -O expand_aliases \
      -i -c \
      "${*}";
    sleep_pure "${sleep_time}";
  done
  \builtin return 0;
}

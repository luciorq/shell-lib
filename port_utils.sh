#!/usr/bin/env bash

function scan_ssh_ports () {
  local output_str;
  local lsof_bin;
  lsof_bin="$(require 'lsof')";
  output_str="$(
    sudo "${lsof_bin}" -i \
      | grep -i 'ssh' \
      | sed 's/\s/###/g' \
      | sed 's/#*#/\t/g' \
      | sed 's/\s(/ (/g' \
      | cut -f 1,3,5,8-
  )";
  builtin echo -ne '* SSH Server ports:\n\n';
  builtin echo -ne 'Not implemented yet\n\n';
  builtin echo -ne '* SSH Client ports (outgoing):\n\n';
  builtin echo -ne \
    'command\tuser\tip_version\tport_type\tname\n';
  builtin echo -ne "${output_str}";
  return 0;
}

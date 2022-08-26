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


# Scan for open TCP ports
# + can accept a range of ports separated by a dash, e.g. '20-80';
# + NOTE: For scanning UDP ports add '-u' do nc command
function scan_port () {
  local _usage="Usage: ${0} <HOST> <PORTS>";
  unset _usage;
  local host_ports;
  local host_name;
  local nc_bin;
  local timeout_bin;
  local bash_bin;
  local _port;
  # 1st method: nc
  nc_bin="$(require 'nc')";
  host_name="${1}";
  host_ports="${2}";
  "${nc_bin}" -z -v \
    "${host_name}" \
    "${host_ports}";

  # 2nd method: through devices redirection
  # + replace 'tcp' to 'udp' in the device string to test UDP ports
  for _port in {20..80}; do
    "${timeout_bin}" 1 \
      "${bash_bin}" -c "</dev/tcp/10.42.0.92/${_port}" \
      &>/dev/null \
      && builtin echo -ne "Port: ${_port} - open\n" \
      || builtin echo -ne "Port: ${_port} - closed\n";
  done
}

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
  local host_port;
  local host_port_end;
  local host_name;
  local nc_bin;
  local timeout_bin;
  local bash_bin;
  local _port;
  nc_bin="$(require 'nc')";
  timeout_bin="$(require 'timeout')";
  bash_bin="$(require 'bash')";
  host_name="${1:-localhost}";
  host_port="${2:-80}";
  host_port_end="${3:-${host_port}}";

  # 1st method: nc
  "${nc_bin}" -z -v \
    "${host_name}" \
    "${host_port}-${host_port_end}";

  # 2nd method: through devices redirection
  # + replace 'tcp' to 'udp' in the device string to test UDP ports
  for _port in $(seq "${host_port}" "${host_port_end}"); do
    "${timeout_bin}" 1 "${bash_bin}" -c \
        "</dev/tcp/${host_name}/${_port}" &>/dev/null \
      && builtin echo -ne "Port: ${_port} - open\n" \
      || builtin echo -ne "Port: ${_port} - closed\n";
  done
  return 0;
}

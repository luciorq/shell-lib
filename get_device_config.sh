#!/usr/bin/env bash

function get_hostname () {
  local hostname_str;
  local hostname_bin;
  local uname_bin;
  hostname_str="${HOSTNAME}";
  hostname_bin="$(which_bin 'hostname')";
  uname_bin="$(which_bin 'uname')";
  if [[ -z ${hostname_str} ]]; then
    if [[ -n ${hostname_bin} ]]; then
      hostname_str="$(hostname)";
    elif [[ -n ${hostname_bin} ]]; then
      hostname_str="$("${uname_bin}" -n)";
    else
      exit_fun "'hostname' command not available";
    fi
  fi
  builtin echo -ne "${hostname_str}";
  return 0;
}


function get_os_arch () {
  local os_arch_str;
  local uname_bin;
  os_arch_str="${HOSTTYPE}";
  uname_bin="$(which_bin 'uname')";

  if [[ -z ${os_arch_str} ]]; then
    if [[ -n ${uname_bin} ]]; then
      os_arch_str="$("${uname_bin}" -m)";
    else
      exit_fun "'uname' command not available";
    fi
  fi
  builtin echo -ne "${os_arch_str}";
  return 0;
}

function get_os_type () {
  local os_type_str;
  local uname_bin;
  os_type_str="${OSTYPE}";
  uname_bin="$(which_bin 'uname')";

  if [[ -z ${os_type_str} ]]; then
    if [[ -n ${uname_bin} ]]; then
      os_type_str="$("${uname_bin}" -s)";
    else
      exit_fun "'uname' command not available";
    fi
  fi

  os_type_str="${os_type_str/[\-1-9]*/}";
  os_type_str="${os_type_str,,}";

  builtin echo -ne "${os_type_str}";
  return 0;
}

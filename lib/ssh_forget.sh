#!/usr/bin/env bash

function ssh_forget () {
  \builtin local keygen_bin;
  \builtin local rm_bin;
  \builtin local _host_name;
  rm_bin="$(which_bin 'rm')";
  keygen_bin="$(require 'ssh-keygen')";

  if [[ -z ${keygen_bin} ]]; then
    exit_fun '`ssh-keygen` is not available on PATH';
    \builtin return 1;
  fi

  for _host_name in "${@}"; do
    "${keygen_bin}" -R "${_host_name}";
  done

  if [[ -f "${HOME}/.ssh/known_hosts.old" ]]; then
    "${rm_bin}" -f "${HOME}/.ssh/known_hosts.old";
  fi
  \builtin return 0;
}

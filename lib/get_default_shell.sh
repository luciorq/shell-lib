#!/usr/bin/env bash

function get_default_shell () {
  \builtin local dscl_bin;
  \builtin local getent_bin;
  dscl_bin="$(which_bin dscl)";
  getent_bin="$(which_bin getent)";
  # MacOS
  if [[ $(get_os_type) =~ 'darwin' ]] && [[ -n "${dscl_bin}" ]]; then
    dscl . -read "${HOME}" UserShell \
      | awk -F': ' '/UserShell/ {print $2}' \
      | sed 's/^[ \t]*//;s/[ \t]*$//';
  # getent respects values in LDAP
  elif [[ -n "${getent_bin}" ]]; then
    "${getent_bin}" passwd \
      | awk -F: -v user="${USER}" '$1 == user {print $NF}';
  else
    grep "^${USER}:" /etc/passwd \
      | cut -d: -f7;
  fi
  \builtin return 0;
}





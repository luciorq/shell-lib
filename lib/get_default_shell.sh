#!/usr/bin/env bash

function get_default_shell () {
  \builtin local _usage;
  _usage="usage: ${0} [<USER_NAME>]";
  \builtin unset _usage;
  \builtin local user_name;
  \builtin local dscl_bin;
  \builtin local getent_bin;
  user_name="${1:-${USER}}";
  if [[ -z "${user_name}" ]]; then
    exit_fun 'User name is empty';
    \builtin return 1;
  fi
  dscl_bin="$(which_bin dscl)";
  getent_bin="$(which_bin getent)";
  # MacOS
  if [[ $(get_os_type) =~ 'darwin' ]] && [[ -n "${dscl_bin}" ]]; then
    dscl . -read "/Users/${user_name}" UserShell \
      | awk -F': ' '/UserShell/ {print $2}' \
      | sed 's/^[ \t]*//;s/[ \t]*$//';
  # getent respects values in LDAP
  elif [[ -n "${getent_bin}" ]]; then
    "${getent_bin}" passwd \
      | awk -F: -v user="${user_name}" '$1 == user {print $NF}';
  else
    grep "^${user_name}:" /etc/passwd \
      | cut -d: -f7;
  fi
  \builtin return 0;
}





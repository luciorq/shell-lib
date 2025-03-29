#!/usr/bin/env bash

# Generate Random Password
function gen_passwd() {
  \builtin local mkpw_bin
  \builtin local gopass_bin
  \builtin local head_bin
  \builtin local pw_str
  mkpw_bin="$(which_bin 'mkpasswd')"
  gopass_bin="$(which_bin 'gopass')"
  head_bin="$(require 'head')"

  if [[ -z ${gopass_bin} ]] && [[ -z ${mkpw_bin} ]]; then
    \builtin echo -ne 'Error: At least one password generator method should be available'
    \builtin return 1
  fi

  if [[ -z ${gopass_bin} ]]; then
    pw_str="$("${mkpw_bin}" ...)"
  else
    pw_str="$(
      "${gopass_bin}" pwgen --symbols --one-per-line 28 |
        "${head_bin}" -1
    )"
  fi

  if [[ -z ${pw_str} ]]; then
    exit_fun 'Password String can not be empty'
    \builtin return 1
  fi

  \builtin echo -ne "${pw_str}"
  \builtin return 0
}

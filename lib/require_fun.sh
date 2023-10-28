#!/usr/bin/env bash

function require_fun () {
  builtin local fun_name;
  fun_name="${1:-}";
  if [[ "$(LC_ALL=C builtin type -t "${fun_name}")" =~ function ]]; then
    builtin echo -ne "${fun_name}";
  else
    exit_fun "require_fun: function \`${fun_name}\` not found";
  fi
  builtin return 0;
}
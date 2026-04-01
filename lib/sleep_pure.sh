#!/usr/bin/env bash

# Pure Bash sleep
function sleep_pure () {
  \builtin local sleep_time;
  sleep_time="${1:-}";

  if [[ -z ${sleep_time} ]]; then
    exit_fun 'invalid option';
    \builtin return 1;
  fi

  if [[ ${OSTYPE} =~ darwin ]]; then
    \builtin command -p sleep "${sleep_time}";
  else
    \builtin read -rt "${sleep_time}" <> <(:) || : ;
  fi
  \builtin return 0;
}

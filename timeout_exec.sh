#!/usr/bin/env bash

# Execute the command with timeout
function timeout_exec () {
  local timeout_bin;
  local cmd_bin;

  local term_time;
  local kill_time;
  term_time='10.0s';
  kill_time='20.0s';

  cmd_bin="${1}";
  timeout_bin="$(require 'timeout')";

  # Try to kill gently with TERM signal after 10s,
  # + if still running ater 20s send KILL signal.
   "${timeout_bin}" \
    --kill-after "${kill_time}" "${term_time}" \
    "${cmd_bin}" "${@}";
   return 0;
}

#!/usr/bin/env bash

# Execute the command with timeout
function timeout_exec () {
  local timeout_bin;
  local cmd_bin;
  local cmd_args;

  local term_time kill_time;
  term_time='10.0s';
  kill_time='20.0s';
  
  cmd_bin=$1;
  cmd_args="${@: 2}";
  timeout_bin="$(check_installed 'timeout --version')";

 # Try to kill gently with TERM signal after 10s,
  # + if still running ater 20s send KILL signal.
   "${timeout_bin}" \
    --kill-after "${kill_time}" "${term_time}" \
    "${cmd_bin}" ${cmd_args};
}

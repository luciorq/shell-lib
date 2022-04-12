#!/usr/bin/env bash

function require () {
  local cmd_str;
  local cmd_args_str;
  cmd_str="$1";
  cmd_args_str="${@:2}";

  check_installed "$cmd_str" ${cmd_args_str[@]};
}

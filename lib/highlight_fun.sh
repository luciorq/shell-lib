#!/usr/bin/env bash

function highlight_fun () {
  \builtin local rg_bin;
  rg_bin="$(require 'rg')";
  "${rg_bin}" --passthru "${@:-}";
  \builtin return 0;
}

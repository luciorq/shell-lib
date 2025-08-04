#!/usr/bin/env bash

function highlight_fun () {
  \builtin local rg_fun;
  rg_fun="$(require 'rg')";
  "${rg_fun}" --passthru "${@:-}";
  \builtin return 0;
}

#!/usr/bin/env bash

# Pure Bash substitute for cat
function cat_pure () {
  local file="$1";
  builtin echo "$(<"${file}")";
  return 0;
}

#!/usr/bin/env bash

# Pure Bash substitute for `cat` program.
function cat_pure () {
  \builtin local file;
  file="${1:-}";
  \builtin echo "$(<"${file}")";
  \builtin return 0;
}

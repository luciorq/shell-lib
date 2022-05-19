#!/usr/bin/env bash

# Check if command line tool is on the path
function is_installed () {
  builtin command -p "${1}" > /dev/null;
  return;
}

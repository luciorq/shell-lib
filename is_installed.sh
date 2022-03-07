#!/usr/bin/env bash

# Check if command line tool is on the path
function is_installed () {
  command -v $1 > /dev/null
}

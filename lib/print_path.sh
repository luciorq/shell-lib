#!/usr/bin/env bash

function print_path () {
  builtin echo -ne "${PATH//:/\\n}\n";
  return 0;
}

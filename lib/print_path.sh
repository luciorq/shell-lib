#!/usr/bin/env bash

function print_path () {
  \builtin echo -ne "${PATH//:/\\n}\n";
  \builtin return 0;
}

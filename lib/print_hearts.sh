#!/usr/bin/env bash

function print_hearts () {
  while sleep 0.07; do
    builtin printf \
      "%-$(( ( RANDOM % $(tput cols) ) - 1))s\e[0;$(( 30 + ( RANDOM % 8) ))m♥\n";
  done
  builtin return 0;
}
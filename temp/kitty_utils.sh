#!/usr/bin/env bash

# Creates a Panel showing which keycode
# + is being processed in the terminal
function show_key_press () {
  local is_kitty;
  is_kitty="$(is_available 'kitty')";
  if [[ ${is_kitty} == true ]]; then
    kitty +kitten show_key -m kitty;
  fi
}



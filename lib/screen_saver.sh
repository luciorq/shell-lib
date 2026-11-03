#!/usr/bin/env bash

# Clears the screen and discards any output, simulating a screen saver effect.
# + Keeps the shell hanging all black, waiting for input (CTRL+C to exit).
# + Usage: screen_saver / CTRL+C to exit
function screen_saver () {
  # \clear; \cat >/dev/null;
  # Restore cursor and echo on exit or interrupt (CTRL+C)
  \builtin trap '\tput cnorm; \stty echo; \clear; trap - INT RETURN; return 0' INT RETURN

  \clear
  \tput civis          # Hide the blinking cursor
  \stty -echo          # Stop typed keys from showing on screen
  \cat >/dev/null      # Ha


  \builtin return 0;
}


function screen_saver_kitty () {
  \builtin local is_kitty;
  is_kitty=0;
  if [[ -n "${KITTY_PID}" || "${TERM}" == "xterm-kitty" ]] \
    && \\builtin command -v kitten >/dev/null 2>&1; then
    is_kitty=1;
  fi

  # Restore cursor, echo, background color, and kitty config on exit or CTRL+C
  \builtin trap '
    \tput cnorm
    \stty echo
    \builtin printf "\e]111\a"
    (( is_kitty )) && \kitten @ load-config --ignore-overrides 2>/dev/null
    \clear
    trap - INT RETURN
    return 0
  ' INT RETURN

  if (( is_kitty )); then
    # Hide tab bar, force pure black background, and remove transparency
    \kitten @ load-config \
      -o tab_bar_style=hidden \
      -o background=#000000 \
      -o background_opacity=1.0 2>/dev/null;
  else
    # Fallback for other terminals: OSC 11 sets background to pure black
    \builtin printf "\e]11;#000000\a";
  fi

  \clear;
  \tput civis;         # Hide cursor
  \stty -echo;         # Hide input keys
  \cat >/dev/null;     # Wait for CTRL+C
}
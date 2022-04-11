#!/usr/bin/env bash

function type_color () {
  local fn_args;
  declare -a fn_args=($@);
  local bat_bin="$(require 'bat')";
  builtin type ${fn_args[@]} \
    | "${bat_bin}" -l 'bash' -p --paging 'never' --theme 'gruvbox-dark';
}

function cat_color () {
  local fn_args;
  declare -a fn_args=($@);
  local bat_bin="$(require 'bat')";
  local cat_bin="$(require 'cat')";
  "${cat_bin}" ${fn_args[@]} \
    | "${bat_bin}" -p --paging 'never' --theme 'gruvbox-dark';
}

# This function only works correctly if the terminal is
# + using 24-bits truecolors
function print_truecolor_scale () {
  builtin echo -ne "'COLORTERM' is '${COLORTERM}' in '${TERM}'";
  awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
      r = 255-(colnum*255/76);
      g = (colnum*510/76);
      b = (colnum*255/76);
      if (g>255) g = 510-g;
      printf "\033[48;2;%d;%d;%dm", r,g,b;
      printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
      printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
  }'
}

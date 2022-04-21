#!/usr/bin/env bash

function type_color () {
  local fn_args;
  declare -a fn_args=(${@});
  local bat_bin="$(require 'bat')";
  builtin type ${fn_args[@]} \
    | "${bat_bin}" -l 'bash' -p --paging 'never' --theme 'gruvbox-dark';
}

function cat_color () {
  local fn_args file_ext;
  declare -a fn_args=(${@});
  local bat_bin="$(require 'bat')";
  local cat_bin="$(require 'cat')";

  file_ext="$(basename ${1})";
  file_ext="${file_ext##*.}";
  if [[ -z ${file_ext} ]]; then
    file_ext="sh";
  fi
  # "${cat_bin}" ${fn_args[@]}
  "${bat_bin}" -p --paging 'never' \
    --theme 'gruvbox-dark' \
    --color auto \
    ${fn_args[@]};
}

# This function only works correctly if the terminal is
# + using 24-bits truecolors
function print_truecolor_scale () {
  local awk_bin;
  awk_bin="$(require 'awk')";
  builtin echo -ne "'COLORTERM' is '${COLORTERM}' in '${TERM}'";
  "${awk_bin}" 'BEGIN{
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

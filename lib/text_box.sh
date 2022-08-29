#!/usr/bin/env bash

function text_box () {
  local s=("$@");
  local b;
  local w;
  local _l;
  local tput_bin;
  tput_bin="$(require 'tput')";

  for _l in "${s[@]}"; do
    ((w<${#_l})) \
      && { b="$_l"; w="${#_l}"; };
  done
  "${tput_bin}" setaf 3;
  builtin echo " -${b//?/-}-
| ${b//?/ } |";
  for _l in "${s[@]}"; do
    builtin printf \
      '| %s%*s%s |\n' \
      "$("${tput_bin}" setaf 4)" "-$w" "$_l" "$("${tput_bin}" setaf 3)";
  done
  builtin echo "| ${b//?/ } |
 -${b//?/-}-";
  "${tput_bin}" sgr 0;
  return 0;
}

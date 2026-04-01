#!/usr/bin/env bash

function fix_quotes () {
  \builtin local SDQUO;
  \builtin local RDQUO;
  \builtin local sed_bin;
  SDQUO="$(\builtin echo -ne '\u2018\u2019')";
  RDQUO="$(\builtin echo -ne '\u201C\u201D')";
  sed_bin="$(require 'sed')";
  "${sed_bin}" -i -e "s/[$SDQUO]/\'/g" -e "s/[$RDQUO]/\"/g" "${1}";
  \builtin return 0;
}

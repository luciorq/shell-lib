#!/usr/bin/env bash

function fix_quotes () {
  local SDQUO=$(builtin echo -ne '\u2018\u2019');
  local RDQUO=$(builtin echo -ne '\u201C\u201D');

  "$(which_bin 'sed')" -i -e "s/[$SDQUO]/\'/g" -e "s/[$RDQUO]/\"/g" "${1}";
  return 0;
}

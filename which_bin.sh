#!/usr/bin/env bash

# Return the first executable on path, without failing
# + but returning warnings
function which_bin () {
  builtin local cmd_arg;
  builtin local cmd_arr;
  builtin local cmd_bin;
  builtin local which_arr;
  builtin local which_bin;
  cmd_arg="${1}";
  builtin mapfile -t which_arr < <(
    builtin command -p which -a 'which' 2> /dev/null || builtin echo -ne ''
  );
  which_bin="${which_arr[0]}";
  if [[ -z ${which_bin} ]]; then
    builtin mapfile -t cmd_arr < <(
      builtin command -v "${cmd_arg}" 2> /dev/null || builtin echo -ne ''
    );
  else
    builtin mapfile -t cmd_arr < <(
      "${which_bin}" -a "${cmd_arg}" 2> /dev/null || builtin echo -ne ''
    );
  fi
  cmd_bin="${cmd_arr[0]}";
  builtin echo -ne "${cmd_bin}";
  builtin return 0;
}


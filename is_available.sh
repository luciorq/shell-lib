#!usr/bin/env bash

# Return "true" or "false" string if command can run properly
function is_available () {
  local cmd_str;
  local cmd_bin;
  cmd_str="$1";
  cmd_bin=$(which_bin "${cmd_str}");
  if [[ -n "${cmd_bin}" ]]; then
    echo -ne 'true';
  else
    # TODO luciorq Check for colored output for command name,
    # + like cli_* functionality in R.
    # + Color 'cmd_str' as path and PATH as variable. 
    >&2 echo -ne "'${cmd_str}' not found in executable \${PATH}.\n";
    echo -ne 'false';
  fi
  return 0;
}

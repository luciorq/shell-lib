#!usr/bin/env bash

# Return "true" or "false" string if command can run properly
function is_available () {
  local cmd_str;
  local cmd_bin;
  cmd_str="$1";
  cmd_bin=$(which_bin "${cmd_str}");
  if [[ -n "${cmd_bin}" ]]; then
    builtin echo -ne 'true';
  else
    # TODO luciorq Check for colored output for command name,
    # + like cli_* functionality in R.
    # + Color 'cmd_str' as path and PATH as variable. 
    builtin echo >&2 -ne "'${cmd_str}' not found in executable \${PATH}.\n";
    builtin echo -ne 'false';
  fi
  return 0;
}

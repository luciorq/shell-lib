#!/usr/bin/env bash

# source script from remote
function source_remote () { 
  builtin local script_url="$1";
  builtin local curl_bin;
  builtin local wget_bin;
  curl_bin=( $(which -a 'curl' || builtin echo -ne '') );
  curl_bin="${curl_bin[0]}";
  wget_bin=( $(which -a 'wget' || builtin echo -ne '') );
  wget_bin="${wget_bin[0]}";

  if [[ -n ${curl_bin} ]]; then
    builtin source /dev/stdin <<< "$("${curl_bin}" -f -s -S -L "${script_url}")";
  elif [[ -n ${wget_bin} ]]; then
    builtin source /dev/stdin <<< "$("${wget_bin}" -q -L -nv -O - "${script_url}")";
  else
    builtin echo >&2 -ne "Download tool not available. Install 'curl' or 'wget' to continue.\n";
    builtin return 1;
  fi
}

# Source functions from remote shell-lib repo
function __source_remote_shell-lib () {
  local fun_name;
  local repo_name;
  local base_url fun_url;
  fun_name="$1";
  repo_name="${2:-luciorq/shell-lib}";
  base_url="https://raw.githubusercontent.com/${repo_name}/main";
  fun_url="${base_url}/${fun_name}.sh";
  builtin echo -ne "* Downloading '${fun_name}.sh'\n";
  source_remote ${fun_url};
  if [[ ! $? -eq 0 ]]; then
    builtin echo >&2 -ne "Failed to find remote file '${fun_url}'\n";
  fi
}

#!/usr/bin/env bash

# This function is supposed to be portable.
# + trying to avoid using features that are not supported by some shells.

# source script from remote
function source_remote () {
  \builtin local script_url;
  \builtin local curl_bin;
  \builtin local wget_bin;
  script_url="${1:-}";
  curl_bin="$(\builtin command -v curl 2>/dev/null || \builtin echo -ne '')";
  wget_bin="$(\builtin command -v wget 2>/dev/null || \builtin echo -ne '')";

  if [[ -n ${curl_bin} ]]; then
    \builtin source /dev/stdin <<< "$("${curl_bin}" -f -s -S -L "${script_url}")";
  elif [[ -n ${wget_bin} ]]; then
    \builtin source /dev/stdin <<< "$("${wget_bin}" -q -L -nv -O - "${script_url}")";
  else
    exit_fun "Download tool not available. Install 'curl' or 'wget' to continue.";
    \builtin return 1;
  fi

  # Return success if the script was sourced without errors
  if [[ ! "${?:-1}" -eq 0 ]]; then
    exit_fun "Failed to source script from '${script_url}'";
    \builtin return 1;
  fi
  \builtin return 0;
}

# Source functions from remote shell-lib repo
function __source_remote_shell-lib () {
  \builtin local fun_name;
  \builtin local repo_name;
  \builtin local base_url;
  \builtin local fun_url;
  fun_name="${1:-}";
  if [[ -z ${fun_name} ]]; then
    exit_fun "'fun_name' can not be empty";
    \builtin return 1;
  fi

  repo_name="${2:-luciorq/shell-lib}";
  base_url="https://raw.githubusercontent.com/${repo_name}/main";
  fun_url="${base_url}/${fun_name}.sh";
  \builtin echo -ne "* Downloading '${fun_name}.sh'\n";

  source_remote "${fun_url}";

  if [[ ! "${?:-1}" -eq 0 ]]; then
    exit_fun "Failed to find remote file '${fun_url}'";
    \builtin return 1;
  fi

  \builtin return 0;
}

#!/usr/bin/env bash

# Start rmote port redirection
# + from: https://github.com/cloudyr/rmote
function rstats::start_rmote () {
  local ssh_bin;
  local remote_host;
  remote_host="${1:-omega}";
  ssh_bin="$(which_bin 'ssh')";
  "${ssh_bin}" -L 4321:localhost:4321 "${remote_host}";
  return 0;
}

# Bootstrap Quarto Markdown Documents
function rstats::boostrap_quarto_install () {
  local quarto_bin;
  quarto_bin="$(which_bin 'quarto')";
  if [[ -z ${quarto_bin} ]]; then
    exit_fun "{quarto} CLI is not installed."
    return 1;
  fi
  "${quarto_bin}" install tool tinytex;
  "${quarto_bin}" install tool chromium;
  return 0;
}

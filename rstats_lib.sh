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

# Install R Packages
rstats::install_pkg () {
  local _usage="Usage: ${0} <> [cran|gh|local|bioc]";
  unset _usage;
  local pkg_name;
  local pkg_type
  local r_bin;
  local num_threads;
  local install_str;
  local script_str;
  pkg_name="${1}";
  pkg_type="${2:-cran}";
  r_bin="$(require 'R')";
  case ${pkg_type} in
    cran)      install_str='install.packages'           ;;
    gh)        install_str='remotes::install_github'    ;;
    local)     install_str='remotes::install_local'     ;;
    bioc*)     install_str='BiocManager::install'       ;;
    *)
      builtin echo >&2 -ne "'${pkg_type}' not available as a Source.\n";
      return 1;
    ;;
  esac
  num_threads="$(get_nthreads 24)";
  script_str="if(isFALSE(base::requireNamespace('${pkg_name}',quietly=TRUE))){${install_str}('${pkg_name}',Ncpus=${num_threads})}";
  "${r_bin}" -q -s -e \
    "${script_str}";
  return 0;
}

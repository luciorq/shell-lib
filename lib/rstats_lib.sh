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
    exit_fun '{quarto} CLI is not installed.';
    return 1;
  fi
  "${quarto_bin}" install tool --no-prompt tinytex;
  "${quarto_bin}" install tool --no-prompt chromium;
  return 0;
}

# Install / update all packages from config file
# TODO: @luciorq Actually implement the universe parsing
function rstats::install_all_pkgs () {
  local pkg_type_arr;
  local pkg_name_arr;
  local _pkg_type;
  local _pkg_name;
  local _pkg_name_arr;
  local pkg_name_str;
  local r_bin;
  local sed_bin;
  r_bin="$(require 'R')";
  sed_bin="$(require 'sed')";
  declare -a pkg_type_arr=(
    'cran'
    'bioc'
    'universe'
    'gh'
    'github'
    'local'
  );
  pkg_name_str='';
  builtin declare -a pkg_name_arr;
  for _pkg_type in "${pkg_type_arr[@]}"; do
    builtin mapfile -t _pkg_name_arr < <(
      get_config rstats_packages "${_pkg_type}_packages"
    );
    if [[ -n ${_pkg_name_arr[*]} ]]; then
      pkg_name_arr+=("${_pkg_name_arr[@]}");
    fi
    for _pkg_name in "${_pkg_name_arr[@]}"; do
      if [[ -n ${_pkg_name} ]]; then
      case ${_pkg_type} in
        cran)
          pkg_name_str="${pkg_name_str}'${_pkg_name}',";
        ;;
        gh|github)
          pkg_name_str="${pkg_name_str}'github::${_pkg_name}',";
        ;;
        local)
          pkg_name_str="${pkg_name_str}'local::${_pkg_name}',";
        ;;
        bioc*)
          pkg_name_str="${pkg_name_str}'bioc::${_pkg_name}',";
        ;;
        universe|runiverse)
          pkg_name_str="${pkg_name_str}'universe::${_pkg_name}',";
        ;;
        *)
          exit_fun "'${pkg_type}' not available as a Source.";
          return 1;
        ;;
      esac
      # rstats::install_pkg "${_pkg_name}" "${_pkg_type}";
      fi
    done
  done

  # builtin echo -ne "${pkg_name_arr[*]}";

  pkg_name_str="$("${sed_bin}" 's/,$//' <<< "${pkg_name_str}")";
  pkg_name_str="c(${pkg_name_str})";

  if [[ -n ${CONDA_DEFAULT_ENV} ]]; then
    local conda_bin;
    local conda_env_name;
    local pkg_conda_deps;
    conda_bin="$(get_conda_bin)";
    conda_env_name="${CONDA_DEFAULT_ENV}";

    # TODO: Check if r-env or base have R installed

    #  pkg_conda_deps="$(rstats::get_pkg_deps "${}")";
    # "${conda_bin}" install \
    #  -n "${conda_env_name}" \
    #   "${pkg_conda_deps}";
  fi
  unset _pkg_name_arr;

  builtin echo -ne \
    "pak::pkg_install(pkg=${pkg_name_str},upgrade=TRUE,ask=FALSE)";
  "${r_bin}" -q -s -e \
    "pak::pkg_install(pkg=${pkg_name_str},upgrade=TRUE,ask=FALSE)";
  return 0;
}

# Install R Packages
# TODO: '--force' flag not implemented yet
# TODO: 'universe' source not implemented yet
function rstats::install_pkg () {
  local _usage="Usage: ${0} <PKG_NAME> [cran|gh|github|local|bioc*|[r]universe] [--force]";
  unset _usage;
  local pkg_name;
  local pkg_type;
  local r_bin;
  local num_threads;
  local install_str;
  local pak_str;
  local script_str;
  local is_pak_available;
  # local force_flag;
  pkg_name="${1}";
  if [[ -z ${pkg_name} ]]; then
    exit_fun 'Package name is not provided.';
    return 1;
  fi
  pkg_type="${2:-cran}";
  r_bin="$(require 'R')";

  if [[ -z ${pkg_name} ]]; then
    exit_fun "Package name is not provided.";
    return 1;
  fi
  case ${pkg_type} in
    cran)
      install_str='install.packages';
      pak_str='';
    ;;
    gh|github)
      install_str='remotes::install_github';
      pak_str='github::';
    ;;
    local)
      install_str='remotes::install_local';
      pak_str='local::~/projects/';
    ;;
    bioc*)
      install_str='BiocManager::install';
      pak_str='bioc::';
    ;;
    universe|runiverse)
      install_str='install.packages';
      pak_str='';
    ;;
    *)
      exit_fun "'${pkg_type}' not available as a Source.";
      return 1;
    ;;
  esac

  is_pak_available="$(
    "${r_bin}" -q -s -e \
      "cat(isTRUE(requireNamespace('pak', quietly=TRUE)))"
  )";

  if [[ ${is_pak_available} == 'TRUE' ]]; then
    script_str="pak::pkg_install('${pak_str}${pkg_name}', upgrade = TRUE, ask = FALSE)";
  else
    num_threads="$(get_nthreads 24)";
    script_str="if(isFALSE(base::requireNamespace('${pkg_name}',quietly=TRUE))){${install_str}('${pkg_name}',Ncpus=${num_threads})}";
  fi
  "${r_bin}" -q -s -e \
    "${script_str}";
  return 0;
}

# Update R language installation to the latest release version
# + only works correctly with devel, release, next
function rstats::install_rstats_version () {
  local rig_bin;
  local os_type;
  local rstats_version;

  rig_bin="$(require 'rig')";
  if [[ -z ${rig_bin} ]]; then
    exit_fun '{rig} CLI is not installed.';
    return 1;
  fi
  rstats_version="${1-release}";
  os_type="$(get_os_type)";
  "${rig_bin}" add "${rstats_version}";
  "${rig_bin}" default "${rstats_version}";
  if [[ ${os_type} == darwin ]]; then
    "${rig_bin}" system  fix-permissions;
    "${rig_bin}" sysreqs add gfortran;
    "${rig_bin}" sysreqs add pkgconfig;
    "${rig_bin}" sysreqs add tidy-html5;
  fi
  "${rig_bin}" system setup-user-lib;
  "${rig_bin}" system add-pak;
  "${rig_bin}" system make-links;
  return 0;
}

# Update current installed R versions
# + devel, release, next
function rstats::update_rstats_version () {
  rstats::install_rig;
  rstats::install_rstats_version devel;
  rstats::install_rstats_version next;
  rstats::install_rstats_version release;
  return 0;
}

# Install RIG - R installation manager
function rstats::install_rig () {
  local rig_bin;
  rig_bin="$(which_bin 'rig')";
  if [[ -z ${rig_bin} ]]; then
    __install_app 'rig';
  fi
  return 0;
}

# Remove installed R package
function rstats::remove_pkg () {
  local r_bin;
  local pkg_name;
  local script_str;
  r_bin="$(require 'R')";
  pkg_name="${1}";
  script_str="utils::remove.packages('${pkg_name}')";
  "${r_bin}" \
    -q -s -e \
    "${script_str}";
  return 0;
}

# ==============================================================================
# Package Development Functions
# ==============================================================================


# TODO: Work in progress for checking and building source R packages

# Check R package
function rstats::check_pkg () {
  local r_bin;
  r_bin="$(require 'R')";

  return 0;
}

# Build R package
function rstats::build_pkg () {
  local r_bin;
  r_bin="$(require 'R')";

  return 0;
}

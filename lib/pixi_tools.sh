#!/usr/bin/env bash

function clean_pixi_and_conda_cache () {
  \builtin local pixi_bin;
  \builtin local micromamba_bin;
  \builtin local mamba_bin;
  \builtin local conda_bin;
  pixi_bin="$(which_bin 'pixi')";
  conda_bin="$(which_bin 'conda')";
  micromamba_bin="$(which_bin 'micromamba')";
  mamba_bin="$(which_bin 'mamba')";

  if [[ -n ${pixi_bin} ]]; then
   "${pixi_bin}" clean cache --yes;
  fi
  if [[ -n ${micromamba_bin} ]]; then
    "${micromamba_bin}" clean --all --yes;
  fi
 if [[ -n ${mamba_bin} ]]; then
    "${mamba_bin}" clean --all --yes;
  fi
  if [[ -n ${conda_bin} ]]; then
    "${conda_bin}" clean --all --yes;
  fi
  \builtin return 0;
}

function pixi_install_pixi_bin () {
  \builtin local pixi_bin;
  pixi_bin="$(which_bin 'pixi')";
  curl_bin="$(which_bin 'curl')";
  bash_bin="$(which_bin 'bash')";

  if [[ -z ${pixi_bin} ]]; then
    if [[ -z ${curl_bin} ]]; then
      \builtin echo -ne "curl is not installed, please install it first\n";
      \builtin return 1;
    fi
    if [[ -z ${bash_bin} ]]; then
      \builtin echo -ne "bash is not installed, please install it first\n";
      \builtin return 1;
    fi
    # TODO: @luciorq Remove dependencies on curl and bash, by just downloading
    # + the executable and moving to the path.
    curl -fsSL https://pixi.sh/install.sh | bash
  else
    \builtin echo -ne "Pixi is already installed at: ${pixi_bin}\n";
    \builtin echo -ne "Pixi will instead try to self update\n";
    pixi_update_pixi_bin;
  fi
  \builtin return 0;
}

function pixi_update_pixi_bin () {
  \builtin local pixi_bin;
  pixi_bin="$(which_bin 'pixi')";
  if [[ -z ${pixi_bin} ]]; then
    \builtin echo -ne "Pixi is not installed, please install it first\n";
    \builtin return 1;
  fi
  "${pixi_bin}" self-update;
  \builtin return 0;
}

function pixi_sync_global_tools () {
  \builtin local pixi_bin;
  pixi_bin="$(which_bin 'pixi')";
  if [[ -z ${pixi_bin} ]]; then
    \builtin echo -ne "Pixi is not installed, please install it first\n";
    \builtin return 1;
  fi
  "${pixi_bin}" global sync;
  \builtin return 0;
}

function pixi_update_global_tools () {
  \builtin local pixi_bin;
  pixi_bin="$(which_bin 'pixi')";
  if [[ -z ${pixi_bin} ]]; then
    \builtin echo -ne "Pixi is not installed, please install it first\n";
    \builtin return 1;
  fi
  "${pixi_bin}" global update;
  \builtin return 0;
}
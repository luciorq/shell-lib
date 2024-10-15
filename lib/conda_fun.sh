#!/usr/bin/env bash

function conda_list_envs () {
  conda_priv_fun 'env' 'list' -q --json;
  \builtin return 0;
}

function conda_env_exists() {
  local env_name
  local jq_bin
  local grep_bin
  local list_envs_res
  jq_bin=$(require 'jq')
  if [[ -z ${jq_bin} ]]; then
    exit_fun 'Install `jq` CLI before continuing';
    \builtin return 1;
  fi
  grep_bin=$(require 'grep')
  env_name="${1:-}"
  if [[ -z ${env_name} ]]; then
    exit_fun 'conda_env_exists: `env_name` not provided'
    builtin return 1
  fi
  list_envs_res="$(
    conda_list_envs |
      "${jq_bin}" -r '.envs[]' |
      "${grep_bin}" "/${env_name}$"
  )"
  builtin echo -ne "${list_envs_res}"
  builtin return 0
}

function conda_run() {
  local env_name
  local conda_env_exists_res
  env_name="${1:-}"
  if [[ -z ${env_name} ]]; then
    exit_fun 'conda_run: `env_name` not provided'
    builtin return 1
  fi
  conda_env_exists_res="$(conda_env_exists "${env_name}")"
  if [[ -z ${conda_env_exists_res} ]]; then
    exit_fun "conda_run: Environment \`${env_name}\` does not exist"
    builtin return 1
  fi
  conda_priv_fun run -n "${env_name}" "${@:2}"
  builtin return 0
}

function conda_create_env () {
  builtin local _usage;
  _usage="${0} <ENV_NAME> <PKGS> [<CHANNELS>] [<PLATFORM>]";
  builtin unset _usage;
  builtin local env_name;
  builtin local pkgs_str;
  builtin local channels_str;
  builtin local conda_env_exists_res;
  builtin local platform_str;
  env_name="${1:-}";
  pkgs_str="${2:-}";
  channels_str="${3:-}";
  platform_str="${4:-}";
  conda_env_exists_res="$(conda_env_exists "${env_name}")";
  if [[ -n ${conda_env_exists_res} ]]; then
    \builtin return 0;
  fi
  if [[ -z ${pkgs_str} ]]; then
    exit_fun 'conda_create_env: Packages not provided';
    \builtin return 1;
  fi

  # TODO: Platform string not added to command yet
  if [[ -z ${platform_str} ]]; then
    platform_str="$(get_conda_platform)";
  fi
  # --platform "${platform_str}"
  \builtin echo -ne "Creating Conda environment: \`${env_name}\`. Please wait...\n";
  conda_priv_fun create -y -q -n "${env_name}" --platform "${platform_str}" --override-channels ${channels_str} ${pkgs_str}

  \builtin echo -ne "Succesfully created: \`${env_name}\`.\n";

  \builtin return 0;
}

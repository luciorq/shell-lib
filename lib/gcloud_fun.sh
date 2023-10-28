#!/usr/bin/env bash

# Run Google Cloud SDK commands inside a conda environment
function gcloud_fun () {
  builtin local env_name;
  env_name="gcloud-env";
  # pkgs_str="google-cloud-sdk";
  # channels_str="";
  conda_create_env "${env_name}" "google-cloud-sdk" "-c conda-forge";
  # TODO(luciorq): Check if command actually exists in the environment
  # + before running
  # + Also, probably add it inside conda_run
  # if [[ -z $(conda_run "${env_name}" command -v gcloud) ]] then
  #   conda_run "${env_name}" gcloud "${@}";
  # fi;
  conda_run "${env_name}" gcloud "${@}";
  builtin return 0;
}

# Run Gcloud commands inside a conda environment
function gsutil_fun () {
  builtin local env_name;
  env_name="gsutil-env";
  conda_create_env "${env_name}" "gsutil" "-c conda-forge";
  conda_run "${env_name}" gsutil "${@}";
  builtin return 0;
}
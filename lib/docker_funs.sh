#!/usr/bin/env bash

# Functions and Wrappers around Docker CLI commands

# Return available memory inside a docker container
function docker_get_available_memory () {
  builtin local docker_bin;
  docker_bin="$(require 'docker')";
  if [[ -z ${docker_bin} ]]; then
    builtin return 1;
  fi
  "${docker_bin}" run \
    --rm \
    "debian:bullseye-slim" \
    bash -c 'numfmt --to iec $(echo $(($(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE))))';
  builtin return 0;
}

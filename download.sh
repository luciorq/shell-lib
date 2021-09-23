#!/bin/env bash

# download file to output
# + if aria2 is available uses multi threaded download
# + if not tries curl, then wget
function download () {
  # usage: download <URL> <OUTPUT_DIR> <THREAD_NUM>
  function download_usage () {
    echo "usage: download <URL> [<OUTPUT_DIR>] [<THREADS>]" 1>&2;
 }
  if [[ $# -eq 0 ]]; then download_usage; unset download_usage; return 1; fi
  unset download_usage
  local get_url dir_output thread_num
  get_url="$1"
  dir_output="$2"
  thread_num="$3"
  if [[ -z "${dir_output}" ]]; then
    dir_output=$(realpath .)
  fi
  if [[ -z "${thread_num}" ]]; then
    thread_num=4
  fi
  mkdir -p "${dir_output}"
  if [[ ! "$(which aria2c)" == "" ]]; then
    aria2c -c \
      -s "${thread_num}" -x "${thread_num}" \
      -j 1 -k 1M -d "${dir_output}" --quiet=true \
      "${get_url}"
  elif [[ ! "$(which curl)" == "" ]]; then
    curl -L \
      -o "${dir_output}/$(basename "${get_url}")" \
      -C - "${get_url}" --silent
  else
    wget --continue -q \
      --no-check-certificate -O "${dir_output}" \
      "${get_url}"
  fi
}


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
  unset download_usage;
  local get_url dir_output thread_num output_filename output_basename;
  local aria2c_bin wget_bin curl_bin;
  get_url="$1";
  dir_output="$2";
  thread_num="$3";

  if [[ -z "${dir_output}" ]]; then
    dir_output=$(realpath .);
  fi
  if [[ -z "${thread_num}" ]]; then
    thread_num=4;
  fi
  if [[ -d "${dir_output}" ]]; then
    "$(which_bin mkdir)" -p "${dir_output}";
  fi
  output_basename=$(basename "${get_url}");
  output_filename="${dir_output}/${output_basename}";

  aria2c_bin="$(which_bin aria2c)";
  wget_bin="$(which_bin wget)";
  curl_bin="$(which_bin curl)";

  if [[ -n "${aria2c_bin}" ]]; then
    "${aria2c_bin}" \
      --continue=true \
      -s "${thread_num}" \
      -x "${thread_num}" \
      -j 1 \
      -k 1M \
      -d "${dir_output}"\
      --out="${output_basename}" \
      --quiet=true \
      --check-integrity=true \
      "${get_url}";
  elif [[ -n "${curl_bin}" ]]; then
    "${curl_bin}" \
      -f -s -S -L \
      --silent \
      -o "${output_filename}" \
      -C - "${get_url}";
  elif [[ -n "${wget_bin}" ]]; then
    "${wget_bin}" \
      --continue \
      -L \
      -nv \
      -q \
      --no-check-certificate \
      --output-document="${output_filename}" \
      "${get_url}";
  else
    echo -ne "No download method available.";
    return 1;
  fi
}

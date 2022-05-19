#!/usr/bin/env bash

# download file to output
# + if aria2 is available uses multi threaded download
# + if not tries curl, then wget
function download () {
  # usage: download <URL> <OUTPUT_DIR> <THREAD_NUM>
  function download_usage () {
    builtin echo >&2 -ne "usage: download <URL> [<OUTPUT_DIR>] [<THREADS>]\n";
  }
  if [[ $# -eq 0 ]]; then download_usage; unset download_usage; return 1; fi
  unset download_usage;
  local get_url dir_output thread_num output_filename output_basename;
  local aria_bin wget_bin curl_bin;
  local cache_path;
  get_url="${1}";
  dir_output="${2}";

  if [[ -z ${dir_output} ]]; then
    dir_output="$(realpath ./)";
  fi
  thread_num="$(get_nthreads 8)";
  if [[ ! -d ${dir_output} ]]; then
    "$(which_bin mkdir)" -p "${dir_output}";
  fi
  output_basename="$(basename "${get_url}")";
  output_filename="${dir_output}/${output_basename}";
  cache_path="${XDG_CACHE_HOME:-${HOME}/.cache}";

  aria_bin="$(which_bin 'aria2c')";
  wget_bin="$(which_bin 'wget')";
  curl_bin="$(which_bin 'curl')";

  if [[ -n ${aria_bin} ]]; then
    "${aria_bin}" \
      --continue=true \
      -s "${thread_num}" \
      -x "${thread_num}" \
      -j 1 \
      -k 1M \
      -d "${dir_output}"\
      --out="${output_basename}" \
      --quiet=true \
      --check-integrity=true \
      --check-certificate=false \
      "${get_url}";
  elif [[ -n ${curl_bin} ]]; then
    "${curl_bin}" \
      -f -s -S -L \
      --create-dirs \
      --insecure \
      --silent \
      -o "${output_filename}" \
      -C - "${get_url}";
  elif [[ -n ${wget_bin} ]]; then
    cache_path="${cache_path}/wget/wget-hsts";
    "${wget_bin}" \
      --continue \
      -L \
      -nv \
      -q \
      --hsts-file="${cache_path}" \
      --no-check-certificate \
      --output-document="${output_filename}" \
      "${get_url}";
  else
    builtin echo >&2 -ne "No download method available.\n";
    return 1;
  fi
  return 0;
}

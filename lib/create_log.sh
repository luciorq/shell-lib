#!/usr/bin/env bash

# Create a Log file
function create_log () {
  local _usage;
  _usage="Usage: ${0} <APP_NAME> [<DIR>]/logs";
  unset _usage;
  local base_path;
  local app_name;
  local log_path;
  local time_str;
  local mkdir_bin;
  local touch_bin;
  local rand_str;
  app_name="${1:-}";
  base_path="${2:-}";
  if [[ -z ${base_path} ]]; then
    base_path="$(\builtin pwd)";
  fi
  mkdir_bin="$(require 'mkdir')";
  if [[ ! -d ${base_path}/logs ]]; then
    "${mkdir_bin}" -p "${base_path}/logs";
  fi
  time_str="$(__get_tz_timestamp)";
  rand_str="$(__get_hash 8)";
  log_path="${base_path}/logs/${app_name}-${time_str}-${rand_str}.log";
  while [[ -f ${log_path} ]]; do
    rand_str="$(__get_hash 8)";
    log_path="${base_path}/logs/${app_name}-${time_str}-${rand_str}.log";
  done
  touch_bin="$(require 'touch')";
  if [[ -n ${touch_bin} ]]; then
    "${touch_bin}" "${log_path}";
  fi
  \builtin echo -ne "${log_path}";
  \builtin return 0;
}

# Get timezone fixed date and time for log timestamp
function __get_tz_timestamp () {
  local timestamp;
  local date_bin;
  date_bin="$(require 'date')";
  timestamp="$(TZ='US/Eastern' "${date_bin}" '+%Y%m%d-%H%M%S')";
  builtin echo -ne "${timestamp}";
  return 0;
}

# Get a random str of hex chars
function __get_hash () {
  local hash_len;
  local hash_str;
  local ssl_bin;
  hash_len="${1:-6}";
  if [[ ${hash_len} -eq 0 ]]; then
    exit_fun "Hash length can not be set to '0'";
    return 1;
  fi
    ssl_bin="$(require 'openssl')";
  if [ -n "${ssl_bin}" ]; then
    hash_str="$("${ssl_bin}" rand -hex "${hash_len}")";
  else
    hash_str="$(__get_hash_fallback "${hash_len}")";
  fi
  \builtin echo -ne "${hash_str: -${hash_len}}";
  \builtin return 0;
}

# Get a random str without with hex chars without openssl
function __get_hash_fallback () {
  local hash_len;
  local i;
  local rand_num;
  local hash_str;
  hash_len="${1:-6}";
  hash_str='';
  for ((i = 0 ; i < hash_len ; i++)); do
    rand_num="$(( 1 + RANDOM % 16 ))";
    case "${rand_num}" in
      1)  hash_str+='0' ;;
      2)  hash_str+='1' ;;
      3)  hash_str+='2' ;;
      4)  hash_str+='3' ;;
      5)  hash_str+='4' ;;
      6)  hash_str+='5' ;;
      7)  hash_str+='6' ;;
      8)  hash_str+='7' ;;
      9)  hash_str+='8' ;;
      10) hash_str+='9' ;;
      11) hash_str+='a' ;;
      12) hash_str+='b' ;;
      13) hash_str+='c' ;;
      14) hash_str+='d' ;;
      15) hash_str+='e' ;;
      *)  hash_str+='f' ;;
    esac
  done
  \builtin echo -ne "${hash_str: -${hash_len}}";
  \builtin return 0;
}

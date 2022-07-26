#!/usr/bin/env bash

# Encrypt Files using the GPG key
# + Note: Recipient is the username/email associated
# + with key
function encrypt () {
  local key_user;
  local gpg_bin;
  local input_file;
  local output_file;

  gpg_bin="$(which_bin 'gpg')";
  if [[ -z "${gpg_bin}" ]]; then
    gpg_bin="$(which_bin 'gpg2')";
  fi
  if [[ -z "${gpg_bin}" ]]; then
    exit_fun "{gpg} is not installed.";
    return 1;
  fi
  key_user="$(get_config --priv user email)";
  input_file="${1}";
  output_file="${2:-${1}.gpg}";
  "${gpg_bin}" \
    --output "${output_file}" \
    --recipient "${key_user}" \
    --encrypt \
    "${input_file}";
  return 0;
}

# Unencrypt files using GPG key
function unencrypt () {
  local key_user;
  local gpg_bin;
  local input_file;
  local output_file;
  gpg_bin="$(which_bin 'gpg')";
  if [[ -z "${gpg_bin}" ]]; then
    gpg_bin="$(which_bin 'gpg2')";
  fi
  if [[ -z "${gpg_bin}" ]]; then
    exit_fun "{gpg} is not installed.";
    return 1;
  fi
  key_user="$(get_config --priv user email)";
  input_file="${1}";
  output_file="${2:-${1%.gpg}}";
  "${gpg_bin}" \
    --output "${output_file}" \
    --recipient "${key_user}" \
    --decrypt \
    "${input_file}";
  return 0;
}

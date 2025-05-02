#!/usr/bin/env bash

# Encrypt file using password
function encrypt_file_password () {
  local file_name;
  local gpg_bin;
  gpg_bin="$(which_bin 'gpg')";
  if [[ -z "${gpg_bin}" ]]; then
    gpg_bin="$(which_bin 'gpg2')";
  fi
  if [[ -z "${gpg_bin}" ]]; then
    exit_fun "{gpg} is not installed.";
    return 1;
  fi
  file_name="${1:-}";
  "${gpg_bin}" \
    -R \
    --encrypt \
    --symmetric \
    --openpgp \
    --cipher-algo AES256 \
    "${file_name}";
  return 0;
}

# Unencrypt file using a password
function unencrypt_file_password () {
  local file_name;
  local gpg_bin;
  gpg_bin="$(which_bin 'gpg')";
  if [[ -z "${gpg_bin}" ]]; then
    gpg_bin="$(which_bin 'gpg2')";
  fi
  if [[ -z "${gpg_bin}" ]]; then
    exit_fun "{gpg} is not installed.";
    return 1;
  fi
  file_name="${1:-}";
  file_name="${file_name%\.gpg}"
  "${gpg_bin}" -d "${file_name}.gpg" > "${file_name}";
  return 0;
}

# Encrypt Files using the GPG key
# + Note: Recipient is the username/email associated
# + with key
function encrypt_file_key () {
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
  input_file="${1:-}";
  output_file="${2:-${input_file}.gpg}";
  "${gpg_bin}" \
    --output "${output_file}" \
    --recipient "${key_user}" \
    --encrypt \
    "${input_file}";
  return 0;
}

# Unencrypt files using GPG key
function unencrypt_file_key () {
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
  input_file="${1:-}";
  output_file="${2:-${input_file%.gpg}}";
  "${gpg_bin}" \
    --output "${output_file}" \
    --recipient "${key_user}" \
    --decrypt \
    "${input_file}";
  return 0;
}

# Encrypt Variable string content
# + Currently only works with `openssl`.
# + If using `libressl` the encryption method is not going to be the same.
# TODO: @luciorq Add `libressl` checking
function encrypt_str () {
  local str_value;
  #local base64_bin;
  str_value="${1:-}";
  #base64_bin="$(require 'base64')";

  #PASSWD=`cat secret.txt \
  #  | openssl enc -aes-256-cbc \
  #    -md sha512 -a -d -pbkdf2 -iter 100000 \
  #    -salt -pass pass:Secret@123#`;

  return 0;
}

# Unencrypt Variable string content
function unencrypt_str () {
  local str_value;
  str_value="${1:-}";
  return 0;
}

#!/usr/bin/env bash

# Create user with specific user ID and password
function __user_create () {
  \builtin local _usage;
  _usage="Usage: ${0} <USER_NAME> <USER_UID> [<PW|PW_HASH>]"
  \builtin unset -v _usage;
  \builtin local user_name;
  \builtin local user_uid;
  \builtin local user_pw;
  \builtin local user_hash_pw;
  \builtin local home_path;
  \builtin local user_shell;
  \builtin local uid_avail;
  \builtin local _hostname;
  \builtin local mkpw_bin;
  \builtin local dirname_bin;
  \builtin local useradd_bin;
  \builtin local grep_bin;
  \builtin local sudo_bin;
  \builtin local is_hashed_pw;
  user_name="${1:-}";
  if [[ -z ${user_name} ]]; then
    exit_fun 'User name can not be empty'
    \builtin return 1
  fi
  user_uid="${2:-}"
  if [[ -z ${user_uid} ]]; then
    exit_fun 'User UID need to be provided';
    \builtin return 1;
  fi
  grep_bin="$(which_bin 'grep')";
  uid_avail="$(
    "${grep_bin}" -v '^#' '/etc/passwd' |
      cut -d':' -f 3 |
      sort -nr |
      "${grep_bin}" "${user_uid}" ||
      \builtin echo -ne ''
  )"
  _hostname="$(get_hostname)"
  if [[ -n ${uid_avail} ]]; then
    exit_fun "'${user_uid}' is not available at host '${_hostname}'";
    \builtin return 1;
  fi
  if [[ -f /usr/bin/bash ]]; then
    user_shell='/usr/bin/bash';
  elif [[ -f /bin/bash ]]; then
    user_shell='/bin/bash';
  fi
  mkpw_bin="$(which_bin 'mkpasswd')"
  dirname_bin="$(which_bin 'dirname')"
  useradd_bin="$(which_bin 'useradd')"
  sudo_bin="$(which_bin 'sudo')"

  user_pw="${3:-}"
  if [[ -z ${user_pw} ]]; then
    user_pw="$(gen_passwd)"
  fi
  home_path="$("${dirname_bin}" "${HOME}")"
  is_hashed_pw="$(
    \builtin echo -ne "${user_pw}" |
      "${grep_bin}" '\$[0-9a-zA-Z]\$' ||
      \builtin echo -ne ''
  )"
  if [[ -z ${is_hashed_pw} ]]; then
    user_hash_pw="$("${mkpw_bin}" -m sha-512 "${user_pw}")"
  else
    user_hash_pw="${user_pw}"
  fi
  "${sudo_bin}" "${useradd_bin}" \
    -m \
    -d "${home_path}/${user_name}" \
    -u "${user_uid}" \
    -s "${user_shell}" \
    -p "${user_hash_pw}" \
    --user-group \
    "${user_name}"
  \builtin echo -ne "${user_pw}\n"
  \builtin return 0
}

# Add user to groups
function __user_add_group () {
  \builtin local _usage;
  _usage="Usage: ${0} <USER_NAME> <GROUP_1> [<GROUP_2> ... <GROUP_N>]";
  \builtin unset -v _usage;
  \builtin local user_name;
  \builtin local args_arr;
  \builtin local groups_to_add;
  \builtin local usermod_bin;
  \builtin local sudo_bin;
  user_name="${1:-}";
  usermod_bin="$(require 'usermod' '-h')";
  sudo_bin="$(require 'sudo')";
  \builtin mapfile -t args_arr < <(\builtin echo "${@:-}");
  groups_to_add="$(
    \builtin echo "${args_arr[@]:1}" |
      sed -r 's|\s+|,|g'
  )"
  "${sudo_bin}" "${usermod_bin}" -a -G "${groups_to_add[@]}" "${user_name}"
  \builtin return 0
}

# Delete User
function __user_remove () {
  \builtin local _usage;
  _usage="Usage: ${0} <USER_NAME>";
  \builtin unset -v _usage;
  \builtin local user_name;
  \builtin local userdel_bin;
  \builtin local sudo_bin;
  userdel_bin="$(require 'userdel' '-h')";
  sudo_bin="$(require 'sudo')";
  user_name="${1:-}";
  if [[ -z "${user_name}" ]]; then
    exit_fun 'User name not supplied';
    \builtin return 1
  fi
  "${sudo_bin}" "${userdel_bin}" -r "${user_name}";
  \builtin return 0
}

# TODO: @luciorq Finish setting replicate_pw function
# Replicate hashed user password
# + from one remote host to another
function __user_replicate_pw_server () {
  \builtin local _usage;
  _usage="Usage: ${0} <USER_NAME> <HOST_FROM> <HOST_TO>";
  \builtin unset -v _usage;
  \builtin local user_name;
  \builtin local host_control_plane;
  # \builtin local host_targets;
  \builtin local grep_bin;
  \builtin local sed_bin;
  \builtin local res_str;
  \builtin local pw_str;
  \builtin local _host;
  \builtin local _host_str;
  \builtin local _host_pw;
  user_name="${1:-}";
  host_control_plane="${2:-}";
  # host_targets=( "${@:3}" );
  grep_bin="$(require 'grep')";
  sed_bin="$(require 'sed')";
  res_str="$(
    exec_remote bioinfo@"${host_control_plane}" \
      'sudo cat /etc/shadow' 2>/dev/null |
      "${grep_bin}" "${user_name}" 2>/dev/null
  )"
  pw_str="$(
    \builtin echo "${res_str}" |
      "${grep_bin}" "${user_name}" |
      "${sed_bin}" -e 's/^\w*://g' |
      "${sed_bin}" -e 's/:[[:digit:]]*:[[:digit:]]:[[:digit:]]*:[[:digit:]]::://g'
  )"
  for _host in "${@:3}"; do
    _host_str="$(
      exec_remote bioinfo@"${_host}" \
        \sudo cat /etc/shadow 2>/dev/null |
        grep "${user_name}" 2>/dev/null
    )"
    _host_pw="$(
      \builtin echo "${_host_str}" |
        "${grep_bin}" "${user_name}" |
        "${sed_bin}" -e 's/^\w*://g' |
        "${sed_bin}" -e \
          's/:[[:digit:]]*:[[:digit:]]:[[:digit:]]*:[[:digit:]]::://g'
    )"
    \builtin echo -ne "Host: ${_host}\n"
    if [[ -z ${_host_pw} ]]; then
      \builtin echo -ne \
        "User {${user_name}} is not available at host {${_host}}\n"
    fi
    \builtin echo "PW: ${_host_pw}";
  done
  \builtin return 0
}

# Create directory structure on `/data` storages
function __create_data_storage_user () {
  \builtin local _usage;
  _usage="Usage: ${0} <USER_NAME>";
  \builtin unset -v _usage;
  \builtin local user_name;
  \builtin local host_name;
  \builtin local user_dir;
  \builtin local mkdir_bin;
  \builtin local chown_bin;
  \builtin local sudo_bin;
  user_name="${1:-}";
  mkdir_bin="$(require 'mkdir')";
  chown_bin="$(require 'chown')";
  sudo_bin="$(require 'sudo')";
  if [[ $(sudo_check) == false ]]; then
    exit_fun 'Need to be run as super user.';
    \builtin return 1
  fi
  if [[ -z ${user_name} ]]; then
    exit_fun "'user_name' can not be empty";
    \builtin return 1;
  fi
  host_name="${HOSTNAME%%.*}"
  if [[ -d /data ]]; then
    user_dir="/data/${host_name}/${user_name}"
    "${sudo_bin}" "${mkdir_bin}" -p "${user_dir}"
    "${sudo_bin}" "${chown_bin}" \
      -R "${user_name}":"${user_name}" "${user_dir}"
  fi
  \builtin return 0;
}

# Create `/data` storage for all users on host
# + This function is intended in being run on multi user machines
function __create_data_storage_all () {
  \builtin local _user_name;
  \builtin local _user_home;
  if [[ -d /home ]]; then
    for _user_home in /home/*; do
      _user_name="${_user_home##*/}"
      __create_data_storage_user "${_user_name}"
    done
  fi
  \builtin return 0
}

#!/usr/bin/env bash

# Create user with specific user ID and password
function __user_create () {
  local _usage="$0: __create_user <USER_NAME> <USER_UID> [<PW>]"
  unset _usage;
  local user_name;
  local user_uid;
  # local user_comment;
  local user_pw;
  local user_hash_pw;
  local home_path;
  local user_shell;
  local uid_avail;
  local _hostname;
  local mkpw_bin;
  local dirname_bin;
  local useradd_bin;
  user_name="${1}";
  if [[ -z ${1} ]]; then
    exit_fun 'User name can not be empty';
    return 1;
  fi
  user_uid=${2};
  if [[ -z ${2} ]]; then
    exit_fun 'User UID need to be provided';
    return 1;
  fi
  uid_avail="$(
    grep -v '^#' /etc/passwd \
      | cut -d':' -f 3 \
      | sort -nr \
      | grep "${user_uid}" \
      || builtin echo -ne ''
  )";
  _hostname="$(get_hostname)";
  if [[ -n ${uid_avail} ]]; then
    exit_fun "'${user_uid}' is not available at host '${_hostname}'";
  fi
  if [[ -f /usr/bin/bash ]]; then
    user_shell='/usr/bin/bash';
  elif [[ -f /bin/bash ]]; then
    user_shell='/bin/bash';
  fi
  mkpw_bin="$(which_bin 'mkpasswd')";
  dirname_bin="$(which_bin 'dirname')";
  useradd_bin="$(which_bin 'useradd')";
  if [[ -n ${3} ]]; then
    user_pw="${3}";
  else
    user_pw="$("${mkpw_bin}" ...)";
  fi
  home_path="$("${dirname_bin}" "${HOME}")";
  user_hash_pw="$("${mkpw_bin}" -m sha-512 "${user_pw}")";
  sudo "${useradd_bin}" \
    -m \
    -d "${home_path}/${user_name}" \
    -u "${user_uid}" \
    -s "${user_shell}" \
    -p "${user_hash_pw}" \
    --user-group \
    "${user_name}";
    builtin echo -ne "${user_pw}\n";
  return 0;
}

# Add user to groups
function __user_add_group () {
  local _usage="Usage: ${0} <USER_NAME> <GROUP_1> [<GROUP_2> ... <GROUP_N>]";
  unset _usage;
  local user_name;
  local args_arr;
  local groups_to_add;
  local usermod_bin;
  local sudo_bin;
  user_name="${1}";
  usermod_bin="$(require 'usermod' '-h')";
  sudo_bin="$(require 'sudo')";
  builtin mapfile -t args_arr < <("${@}");
  groups_to_add="$(
    builtin echo "${args_arr[@]:1}" \
      | sed -r 's|\s+|,|g'
  )";
  "${sudo_bin}" "${usermod_bin}" -a -G "${groups_to_add}" "${user_name}";
  return 0;
}

# Delete User
function __user_remove () {
  local _usage="Usage: ${0} <USER_NAME>";
  unset _usage;
  local user_name;
  local userdel_bin;
  local sudo_bin;
  userdel_bin="$(require 'userdel' '-h')";
  sudo_bin="$(require 'sudo')";
  user_name="${1}";
  "${sudo_bin}" "${userdel_bin}" -r "${user_name}";
  return 0;
}


# TODO(luciorq): Finish setting replacte_pw function
# Replicate hashed user password
# + from one remote host to another
function __replicate_pw_server () {
  local _usage="Usage: {0} <USER_NAME> <HOST_FROM> <HOST_TO>";
  unset _usage;
  local user_name;
  local host_from;
  local host_to;
  user_name="${1}";

  return 0;
}

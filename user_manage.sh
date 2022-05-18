#!/usr/bin/env bash

function __user_create () {
  local _usage="$0: __create_user <USER_NAME> <USER_UID> <PW>"
  unset _usage;
  local user_name;
  local user_uid;
  local user_comment;
  local user_pw;
  local user_hash_pw;
  local home_path;
  local user_shell;
  local uid_avail;
  local _hostname;
  local mkpw_bin;
  user_name="${1}";
  user_uid=${2};
  uid_avail="$(
    cat /etc/passwd \
      | grep -v '^#' \
      | cut -d':' -f 3 \
      | sort -nr \
      | grep "${user_uid}"
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
  mkpw_bin="$(require mkpasswd)";
  if [[ -n ${3} ]]; then
    user_pw="${3}";
  else
    user_pw="$(mkpasswd ...)";
  fi
  home_path="$(dirname ${HOME})";
  user_hash_pw="$(mkpasswd -m sha-512 ${user_pw})";
  sudo useradd \
    -m \
    -d "${home_path}/${user_name}" \
    -u "${user_uid}" \
    -s "${user_shell}" \
    -p "${user_hash_pw}" \
    --user-group \
    "${user_name}";
    builtin echo -ne "${user_pw}\n";
}

function __user_add_group () {
  local user_name;
  local args_arr;
  local groups_to_add;
  user_name="${1}";
  builtin mapfile -t args_arr < <($@);
  groups_to_add=$(builtin echo "${args_arr[@]:1}" | sed -r 's|\s+|,|g');
  sudo usermod -a -G "${groups_to_add}" "${user_name}";
  return 0;
}

function __user_remove () {
  local user_name;
  user_name="${1}";
  sudo userdel -r "${user_name}";
  return 0;
}

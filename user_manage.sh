#!/usr/bin/env bash

# Create user with specific user ID and password
function __user_create () {
  local _usage="$0: __create_user <USER_NAME> <USER_UID> [<PW|PW_HASH>]"
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
  local grep_bin;
  local sudo_bin;
  local is_hashed_pw;
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
  grep_bin="$(which_bin 'grep')";
  uid_avail="$(
    "${grep_bin}" -v '^#' /etc/passwd \
      | cut -d':' -f 3 \
      | sort -nr \
      | "${grep_bin}" "${user_uid}" \
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
  sudo_bin="$(which_bin 'sudo')";
  if [[ -n ${3} ]]; then
    user_pw="${3}";
  else
    user_pw="$("${mkpw_bin}" ...)";
  fi
  home_path="$("${dirname_bin}" "${HOME}")";

  is_hashed_pw="$(
    builtin echo -ne "${user_pw}" \
      |"${grep_bin}" '\$[0-9]\$'
  )";
  if [[ -z ${is_hashed_pw} ]]; then
    user_hash_pw="$("${mkpw_bin}" -m sha-512 "${user_pw}")";
  else
    user_hash_pw="${user_pw}";
  fi
  "${sudo_bin}" "${useradd_bin}" \
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


# TODO(luciorq): Finish setting replicate_pw function
# Replicate hashed user password
# + from one remote host to another
function __replicate_pw_server () {
  local _usage="Usage: {0} <USER_NAME> <HOST_FROM> <HOST_TO>";
  unset _usage;
  local user_name;
  local host_control_plane;
  local host_targets;
  local grep_bin;
  local sed_bin;
  local res_str;
  local pw_str;
  local _host;
  local _host_str;
  local _host_pw;
  user_name="${1}";
  host_control_plane="${2}";
  # host_targets=( "${@:3}" );

  grep_bin="$(require 'grep')";
  sed_bin="$(require 'sed')";
  res_str="$(
    exec_remote bioinfo@"${host_control_plane}" \
      'sudo cat /etc/shadow' 2> /dev/null \
      | "${grep_bin}" "${user_name}" 2> /dev/null
  )";
  pw_str="$(
    builtin echo "${res_str}" \
    | "${grep_bin}" "${user_name}" \
    | "${sed_bin}" -e 's/^\w*://g' \
    | "${sed_bin}" -e 's/:[[:digit:]]*:[[:digit:]]:[[:digit:]]*:[[:digit:]]::://g'
  )";

  for _host in "${@:3}"; do
    _host_str="$(
      exec_remote bioinfo@"${_host}" \
        sudo cat /etc/shadow 2> /dev/null \
        | grep "${user_name}" 2> /dev/null
    )";
    _host_pw="$(
      builtin echo "${_host_str}" \
      | "${grep_bin}" "${user_name}" \
      | "${sed_bin}" -e 's/^\w*://g' \
      | "${sed_bin}" -e \
        's/:[[:digit:]]*:[[:digit:]]:[[:digit:]]*:[[:digit:]]::://g'
    )";
    echo "${_host}";
    if [[ -z ${_host_pw} ]]; then
      builtin echo -ne \
        "User {${user_name}}";
    fi
    echo "${_host_pw}";
  done

  return 0;
}

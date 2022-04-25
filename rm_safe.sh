#!/usr/bin/env bash

# rm with safe measures by default
function rm_safe () {
  local rm_bin;
  local safe_dirs_arr _safe_dir;
  local safe_path;
  local _arg;
  local path_arg;
  rm_bin="$(which_bin 'rm')";
  declare -a safe_dirs_arr=(
    "${HOME}"
    "${HOME}/Documents"
    "${HOME}/documents"
    "${HOME}/projects"
    "${HOME}/workspaces"
    '${HOME}'
    "/Users/${USER}"
    "/home/${USER}"
    '/home/${USER}'
    '/root'
    '/home'
    '/data'
    '/System'
    '/User'
    '/Volumes'
    '/'
  )
  for _arg in "${@}"; do
    path_arg="$(realpath 2> /dev/null "${_arg}" || builtin echo -ne '')";
    if [[ -n ${path_arg} ]]; then
      for _safe_dir in "${safe_dirs_arr[@]}"; do
        safe_path="$(realpath 2> /dev/null "${_safe_dir}" || builtin echo -ne '')";
        if [[ ${safe_path} == "${path_arg}" ]]; then
          builtin echo -ne \
            "Error: '${safe_path}' is a **protected** directory. Don't delete it!\n";
          return 1;
        fi
      done
    fi
  done
  "${rm_bin}" "${@}";
}

#!/usr/bin/env bash

# Remove file or directory, with some safe measures by default
function rm_safe () {
  builtin local rm_bin;
  builtin local realpath_bin;
  builtin local safe_dirs_arr;
  builtin local _safe_dir;
  builtin local safe_path;
  builtin local _arg;
  builtin local path_arg;
  rm_bin="$(which_bin 'rm')";
  if [[ -z ${rm_bin} ]]; then
    exit_fun "'rm' command not available on \${PATH}";
    builtin return 1;
  fi
  realpath_bin="$(which_bin 'realpath')";
  declare -a safe_dirs_arr=(
    "${HOME}"
    "${HOME}/Documents"
    "${HOME}/documents"
    "${HOME}/projects"
    "${HOME}/workspaces"
    "/Users/${USER}"
    "/home/${USER}"
    '${HOME}'
    '/Users/${USER}'
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
    path_arg="$("${realpath_bin}" 2> /dev/null "${_arg}" || builtin echo -ne '')";
    if [[ -n ${path_arg} ]]; then
      for _safe_dir in "${safe_dirs_arr[@]}"; do
        safe_path="$(
          "${realpath_bin}" 2> /dev/null "${_safe_dir}" || builtin echo -ne ''
        )";
        if [[ ${safe_path} == "${path_arg}" ]]; then
          builtin echo -ne \
            "Error: '${safe_path}' is a **protected** directory. Don't delete it!\n";
          builtin return 1;
        fi
      done
    fi
  done
  "${rm_bin}" "${@}";
  builtin return 0;
}

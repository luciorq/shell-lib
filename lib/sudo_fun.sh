#!/usr/bin/env bash

# Allow for sudo with aliases or custom functions,
# + also shows alias expanded command and command type.
function sudo_fun () {
  builtin local sudo_bin;
  builtin local bash_bin;
  builtin local cmd_str;
  builtin local cmd_type;
  builtin local args_q;
  builtin local args_str;
  builtin local cmd_prep;
  sudo_bin="$(which_bin 'sudo')";
  if [[ -z "${sudo_bin}" ]]; then
    exit_fun "'sudo' is not available ...";
    \builtin return 1;
  fi
  if [[ ${#} -eq 0 ]]; then
    "${sudo_bin}";
    \builtin return;
  fi

  cmd_str="${1:-}";
  if [[ "${cmd_str}" == '--help' ]] ||
    [[ "${cmd_str}" == '-h' ]] ||
    [[ "${cmd_str}" == '-l' ]] ||
    [[ "${cmd_str}" == '--version' ]] ||
    [[ "${cmd_str}" == '-V' ]]; then
    "${sudo_bin}" "${cmd_str}";
    \builtin return;
  fi

  if [[ -d "${cmd_str}" ]]; then
    exit_fun "'${cmd_str}' is a directory.";
    \builtin return 1;
  fi

  bash_bin="$(which_bin 'bash')";

  cmd_prep="shopt -s expand_aliases; _SUDO_FUN=true; TERM=xterm-256color; ";


  declare -a args_q=("${@@Q}");
  args_str="${args_q[*]:1}";

  cmd_type="$(
    _SUDO_FUN=true "${bash_bin}" -i -c \
      "${cmd_prep} LC_ALL=C \builtin type -t '${cmd_str}';"
  )";

  case "${cmd_type}" in
    file) type_str="Normal";;
    builtin) type_str="Shell Builtin";;
    alias) type_str="Alias";;
    function) type_str="Function";;
    *) exit_fun "Unknown command '${cmd_type}' type for '${cmd_str}'."; \builtin return 1;;
  esac

  \builtin echo >&2 -ne "* Command type:\n";
  \builtin echo >&2 -ne "\t--> ${type_str}\n";

  # builtin echo -ne "eval \"${*@Q}\";\n";
  "${sudo_bin}" _SUDO_FUN=true "${bash_bin}" \
    -O expand_aliases \
    -i -c \
    "${cmd_prep}eval ${cmd_str} \"${args_str}\"";

  \builtin return 0;
}

#!/usr/bin/env bash

# Allow for sudo with aliases or custom functions,
# + also shows alias expanded command and command type.
function sudo_fun () {
  builtin local sudo_bin bash_bin;
  builtin local cmd_str;
  builtin local cmd_type;
  builtin local args_q;
  builtin local args_str;
  builtin local cmd_prep;
  sudo_bin="$(which_bin 'sudo')";
  if [[ -z ${sudo_bin} ]]; then
    exit_fun "'sudo' is not available ...";
  fi
  if [[ ${1} == '--help' || ${1} == '-h' ]]; then
    "${sudo_bin}" --help;
    return;
  fi

  if [[ $# -eq 0 ]]; then
    "${sudo_bin}";
    return;
  fi

  bash_bin="$(which_bin 'bash')";

  cmd_prep="shopt -s expand_aliases; _SUDO_FUN=true; TERM=xterm-256color; ";

  cmd_str="${1}";

  declare -a args_q=("${@@Q}");
  args_str="${args_q[*]:1}";

  cmd_type="$(
    _SUDO_FUN=true "${bash_bin}" -i -c \
      "${cmd_prep} builtin type -t '${cmd_str}';"
  )";

  case "${cmd_type}" in
    file) type_str="Normal";;
    builtin) type_str="Shell Builtin";;
    alias) type_str="Alias";;
    function) type_str="Function";;
    *) exit_fun "Unknown command '${cmd_type}' type for '${cmd_str}'.";;
  esac

  builtin echo -ne "* Command type:\n";
  builtin echo -ne "\t--> ${type_str}\n";

  # builtin echo -ne "eval \"${*@Q}\";\n";
  "${sudo_bin}" _SUDO_FUN=true "${bash_bin}" \
    -O expand_aliases \
    -i -c \
    "${cmd_prep}eval ${cmd_str} \"${args_str}\"";

  return 0;
}

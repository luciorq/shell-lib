#!/usr/bin/env bash

# Allow for sudo with aliases or custom functions,
# + also shows alias expanded command and command type.
function sudo_fun () {
  builtin local cmd_str;
  builtin local cmd_str_arr;
  builtin local type_str;
  builtin local aux_str;
  builtin local cmd_bin;
  builtin local cmd_bin_arr;
  builtin local args_arr aux_arr;
  builtin local sudo_bin bash_bin;
  builtin local sudo_bin_arr bash_bin_arr;
  builtin local dot_sym arrow_sym;
  builtin local alias_arg alias_args_arr;
  builtin local fun_str;
  dot_sym='*';
  arrow_sym='-->';

  builtin mapfile -t sudo_bin_arr < <(
    builtin command which -a 'sudo' || builtin echo -ne ''
  );
  sudo_bin="${sudo_bin_arr[0]}";
  if [[ -z ${sudo_bin} ]]; then
    builtin return 1;
  fi
  if [[ ${1} == '--help' || ${1} == '-h' ]]; then
    "${sudo_bin}" --help;
  fi

  if [[ $# -eq 0 ]]; then
    "${sudo_bin}";
  fi

  builtin mapfile -t bash_bin_arr < <(
    builtin command which -a 'bash' || builtin echo -ne ''
  );
  bash_bin="${bash_bin_arr[0]}";

  cmd_str="${1}";

  builtin echo -ne "${dot_sym} Command type:\n";

  aux_str='';
  type_str=$(builtin type -a "${cmd_str}" 2> /dev/null | head -1);
  alias_args_arr='';
  while [[ "${type_str}" == *'is aliased to'* ]]; do
    builtin echo -ne "${arrow_sym} Alias\n";
    aux_str=$(
      builtin type -a "${cmd_str}" | head -1 | grep -o -P "(?<=\`).*(?=')"
    );
    builtin mapfile -t aux_arr < <(
      builtin echo "${aux_str}"
    );
    alias_args_arr="${aux_arr[@]:1} ${alias_args_arr}";
    cmd_str=(${aux_arr[0]});
    builtin mapfile -t  cmd_bin_arr < <(
      builtin command which -a "${cmd_str}" || builtin echo -ne ''
    );
    cmd_bin="${cmd_bin_arr[0]}";
    type_str=$(builtin type -a "${cmd_str}" 2> /dev/null | head -1);
    if [[ "${type_str}" == *'is a function'* ]]; then
      break
    elif [[ -n ${cmd_bin} ]]; then
      break
    fi
  done
  # declare -a args_arr=(${@@Q})
  builtin mapfile -t cmd_bin_arr < <(
    builtin command which -a "${cmd_str}" || builtin echo -ne ''
  );
  cmd_bin="${cmd_bin_arr[0]}";
  cmd_str="${cmd_str[0]}";
  if [[ "${type_str}" == *'is a function'* ]]; then
    builtin echo -ne "${arrow_sym} Function\n";
    fun_str=$(declare -f "${cmd_str}");
    "${sudo_bin}" "${bash_bin}" -c \
      "eval \"${fun_str}\"; TERM=\'xterm-256color\' ${cmd_str} ${alias_args_arr[@]} ${@:1};";
  else
    builtin echo -ne "${arrow_sym} Normal\n";
    "${sudo_bin}" TERM='xterm-256color' "${cmd_bin}" "${alias_args_arr[@]:1}" "${args_arr[@]:1}";
  fi
}

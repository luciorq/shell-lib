#!/usr/bin/env bash

# Allow for sudo with aliases or custom functions,
# + also shows alias expanded command and command type.
function sudo () {
  builtin local cmd_str type_str aux_str args_str;
  builtin local cmd_bin alias_cmd_bin args_arr aux_arr;
  builtin local sudo_bin bash_bin;
  builtin local dot_sym bullet_sym arrow_sym;
  builtin local space_regex;
  builtin local alias_arg alias_args_arr;
  builtin local aux_arg;
  builtin local fun_str;
  dot_sym='*';
  bullet_sym='⦿';
  arrow_sym='-->';

  if [[ ! ${SHELL} =~ bash ]]; then
    sudo $@;
  fi
  declare -a sudo_bin=($(builtin command which -a 'sudo' || builtin echo -ne ''));
  sudo_bin="${sudo_bin[0]}";
  if [[ -z ${sudo_bin} ]]; then
    builtin return 1;
  fi
  # declare Quoted array
  if [[ -z ${@} ]]; then
    "${sudo_bin}";
  fi

  declare -a bash_bin=($(builtin command which -a 'bash' || builtin echo -ne ''));
  bash_bin="${bash_bin[0]}";
  cmd_str="${1}";
  #space_regex="[[:space:]]+"
  #if [[ $string =~ $space_regex ]]; then
  #fi

  builtin echo -ne "${dot_sym} Command type:\n";
  aux_str='';
  type_str=$(builtin type -a ${cmd_str} 2> /dev/null | head -1);
  alias_args_arr='';
  while [[ "${type_str}" == *'is aliased to'* ]]; do
    builtin echo -ne "${arrow_sym} Alias\n";
    aux_str=$(builtin type -a "${cmd_str}" | head -1 | grep -o -P "(?<=\`).*(?=')");
    declare -a aux_arr=( ${aux_str} );
    alias_args_arr="${aux_arr[@]:1} ${alias_args_arr}";
    cmd_str=(${aux_arr[0]});
    declare -a cmd_bin=($(builtin command which -a ${cmd_str} || builtin echo -ne ''));
    cmd_bin="${cmd_bin[0]}";
    type_str=$(builtin type -a ${cmd_str} 2> /dev/null | head -1);
    if [[ "${type_str}" == *'is a function'* ]]; then
      break
    elif [[ -n ${cmd_bin} ]]; then
      break
    fi
  done
  declare -a args_arr=("${@@Q}")
  declare -a cmd_bin=($(builtin command which -a ${cmd_str} || builtin echo -ne ''));
  cmd_bin="${cmd_bin[0]}";
  cmd_str=${cmd_str[0]};
  if [[ "${type_str}" == *'is a function'* ]]; then
    builtin echo -ne "${arrow_sym} Function\n";
    fun_str=$(declare -f ${cmd_str});
    eval "${sudo_bin}" "${bash_bin}" -c \
      "'${fun_str}'; ${cmd_str} ${alias_args_arr[@]} ${args_arr[@]:1}";
  else
    builtin echo -ne "${arrow_sym} Normal\n";
    builtin eval "${sudo_bin}" "${cmd_bin}" ${alias_args_arr[@]} ${args_arr[@]:1};
  fi
}

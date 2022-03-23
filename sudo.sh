#!/usr/bin/env bash

# Allow for sudo with aliases or custom functions,
# + also shows alias expanded command and command type.
# type -a <YOUR COMMAND HERE> | grep -o -P "(?<=\`).*(?=')" | xargs sudo
function sudo () {
  builtin local cmd_str type_str aux_str args_str;
  builtin local sudo_cmd;
  
  builtin local dot_sym bullet_sym arrow_sym;
  dot_sym='*';
  bullet_sym='⦿';
  arrow_sym='-->';

  cmd_str="$1";
  sudo_cmd=$( (which -a sudo || echo "") | head -1 );

  if [[ -z ${sudo_cmd} ]]; then        
    builtin return 1;        
  fi

  args_str="${@}";
  type_str=$(type -a "${cmd_str}" 2> /dev/null | head -1);
  aux_str='';
  
  builtin echo -ne "${dot_sym} Command type:\n";
  
  if [[ "${type_str}" == *'is a function'* ]]; then
    builtin echo -ne "${arrow_sym} Function\n";
    aux_str=$(declare -f "${cmd_str}");
    # The printed command is not the actual command; see bash -c invocation under here
    builtin echo -ne "${bullet_sym} ${sudo_cmd} ${args_str}\n\n";
    ${sudo_cmd} bash -c "${aux_str}; ${args_str}";
  elif [[ "${type_str}" == *'is aliased to'* ]]; then 
    builtin echo -ne "${arrow_sym} Alias\n";
    aux_str=$(type -a "${cmd_str}" | head -1 | grep -o -P "(?<=\`).*(?=')");
    args_str=$(echo "${args_str}" | sed "s|${cmd_str}|${aux_str}|g");
    builtin echo -ne "${bullet_sym} ${sudo_cmd} ${args_str}\n\n";
    ${sudo_cmd} ${args_str};
  else
    builtin echo -ne "${arrow_sym} Normal\n";
    builtin echo -ne "${bullet_sym} ${sudo_cmd} ${args_str}\n\n";
    ${sudo_cmd} ${args_str};
  fi
}

#!/usr/bin/env bats

function setup () {
  source lib/which_bin.sh
  source lib/exit_fun.sh
  source lib/is_available.sh
  source lib/require.sh
  source lib/color_cmds.sh
  source lib/bat_fun.sh
}

@test "'type' - Syntax highlight" {
  local builtin_output="$(builtin type -a 'type_color')";
  run type_color -a 'type_color';
  [ "${status}" -eq 0 ];
  [ "${output}" = "${builtin_output}" ];
  unset status;
  unset output;

  PATH='' run type_color -a 'type_color';
  [ "${status}" -eq 0 ];
  [ "${output}" = "${builtin_output}" ];
}

@test "'cat' - Syntax highlight" {
  local cat_bin="$(which cat)";
  local default_output="$("${cat_bin}" lib/which_bin.sh)";
  run cat_color lib/which_bin.sh;
  [ "${status}" -eq 0 ];
  # diff <("$default_output") <("${output}")
  [ "${output}" = "${default_output}" ];
  unset status;
  unset output;

  local cat_path="$(dirname "${cat_bin}")";
  PATH="${cat_path}" run cat_color lib/which_bin.sh;
  [ "${status}" -eq 0 ];
  [ "${output}" = "${default_output}" ];
  unset status;
  unset output;

  PATH='' run cat_color lib/which_bin.sh;
  echo "$output"
  [ "${status}" -eq 1 ];
  [[ "${output}" =~ "Error: 'cat' executable not found in '\${PATH}'" ]];

}

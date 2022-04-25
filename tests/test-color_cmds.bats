#!/usr/bin/env bats

function setup () {
  source which_bin.sh
  source exit_fun.sh
  source is_available.sh
  source require.sh
  source color_cmds.sh
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
  local default_output="$("${cat_bin}" which_bin.sh)";
  run cat_color which_bin.sh;
  [ "${status}" -eq 0 ];
  # diff <("$default_output") <("${output}")
  [ "${output}" = "${default_output}" ];
  unset status;
  unset output;

  local cat_path="$(dirname "${cat_bin}")";
  PATH="${cat_path}" run cat_color which_bin.sh;
  [ "${status}" -eq 0 ];
  [ "${output}" = "${default_output}" ];
  unset status;
  unset output;

  PATH='' run cat_color which_bin.sh;
  echo "$output"
  [ "${status}" -eq 1 ];
  [[ "${output}" =~ "'cat' not found in executable \${PATH}" ]];

}

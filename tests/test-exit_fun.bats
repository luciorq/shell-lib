#!/usr/bin/env bats

function setup () {
  source exit_fun.sh
}

@test "'exit_fun' - Exit from outer function call" {
  function test_exit_fun () {
    [[ -z ${1} ]] && exit_fun "Empty arg";
    builtin echo "${1}: OK";
  }
  run test_exit_fun 'First arg';
  [ "${status}" -eq 0 ];
  [ "${output}" = 'First arg: OK' ];
  unset status
  unset output
  run test_exit_fun;
  echo "$output"
  [ "${status}" -eq 1 ];
  [[ ${output} = 'exit_fun.sh: line 5: Error: Empty arg' ]];
  [[ ! ${output} =~ ': OK' ]];
}

@test "'exit_fun' - Exit from script file" {
  run bash tests/test-exit_outer_function.sh;
  [ "${status}" -eq 1 ];
  [[ ${output} =~ 'exit_fun.sh: line 5: Error: This command failed' ]];
  [[ ! ${output} =~ 'Output that should not be printed' ]];
  [[ ${output} =~ 'Normal output' ]];
}

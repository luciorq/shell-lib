#!/usr/bin/env bats

function setup () {
  source lib/which_bin.sh
  source lib/exit_fun.sh
  source lib/is_available.sh
  source lib/require.sh
}


@test "'require' - Common tool" {
  ls_bin="$(which 'ls')";
  run require 'ls';
  [ "${status}" -eq 0 ];
  [ "${output}" = "${ls_bin}" ];
}

@test "'require' - Empty PATH" {
  # output="$(PATH='' require 'ls' 2>&1)";
  # status="$?";
  PATH='' run require 'ls';
  [ "${status}" -eq 1 ];
  [[ ${output} =~ "executable not found in '\${PATH}'" ]];
}

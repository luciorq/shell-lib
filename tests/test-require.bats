#!/usr/bin/env bats

function setup () {
  source which_bin.sh
  source exit_fun.sh
  source is_available.sh
  source require.sh
}


@test "require - Common tool" {
  ls_bin="$(which 'ls')";
  run require 'ls';
  [ "${status}" -eq 0 ];
  [ "${output}" = "${ls_bin}" ];
}

@test "require - Empty PATH" {
  # output="$(PATH='' require 'ls' 2>&1)";
  # status="$?";
  PATH='' run require 'ls';
  [[ ${output} =~ "not found in executable \${PATH}" ]];
  [ "${status}" -eq 1 ];
}

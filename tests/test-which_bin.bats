#!/usr/bin/env bats

function setup () {
  source which_bin.sh
}

@test "which_bin - Finds ls binary" {
  ls_bin="$(which ls)";
  run which_bin 'ls';
  [ "${status}" -eq 0 ];
  [ "${output}" = "${ls_bin}" ];
}

@test "which_bin - works with empty PATH" {
  PATH='' run which_bin 'which';
  [ "${status}" -eq 0 ];
  [ "${output}" = '' ];
}

@test "which_bin - Works without 'which' on PATH" {
  touch tests/test_exec.sh
  chmod +x tests/test_exec.sh
  PATH="${PWD}/tests" run which_bin 'test_exec.sh';
  [ "${status}" -eq 0 ];
  [ "${output}" = "${PWD}/tests/test_exec.sh" ];
  rm tests/test_exec.sh
}

@test "Finds executable in custom PATH" {
  touch tests/test_exec.sh
  chmod +x tests/test_exec.sh
  PATH="${PATH}:${PWD}/tests" run which_bin 'test_exec.sh';
  [ "${status}" -eq 0 ];
  [ "${output}" = "${PWD}/tests/test_exec.sh" ];
  rm tests/test_exec.sh
}

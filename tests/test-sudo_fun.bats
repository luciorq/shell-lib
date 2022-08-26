#!/usr/bin/env bats

function setup () {
  source lib/which_bin.sh;
  source lib/exit_fun.sh;
  source lib/sudo_fun.sh;
  alias ls='exa -g';
  _target_path="$(dirname $(dirname "${BATS_TEST_FILENAME}"))";
  sudo_bin="$(which sudo)";
  ls_bin="$(which ls)";
}

@test "'sudo_fun' - Normal command" {
  default_output="$("${sudo_bin}" "${ls_bin}" "${_target_path}")";
  run sudo_fun "${ls_bin}" "${_target_path}";
  [ "${status}" -eq 0 ];
  [[ "${output}" =~ "* Command type:" ]];
  [[ "${output}" =~ "Normal" ]];
  [[ "${output}" =~ "${default_output}" ]];
}

@test "'sudo_fun' - Expand alias" {
  default_output="$("${sudo_bin}" exa -g "${_target_path}")";
  run sudo_fun ls "${_target_path}";
  echo "${output}";
  #echo "----------------------------------------------------";
  #echo "${default_output}";
  [ "${status}" -eq 0 ];
  [[ "${output}" =~ "* Command type:" ]];
  [[ "${output}" =~ "Alias" ]];
  #[[ "${output}" =~ "Normal" ]];
  [[ "${output}" =~ "${default_output}" ]];
}

@test "'sudo_fun' - Expand functions" {
  default_output="$(which ls)";
  run sudo_fun which_bin ls;
  [ "${status}" -eq 0 ];
  [[ "${output}" =~ "Function" ]];
  [[ "${output}" =~ "${default_output}" ]];
}

@test "'sudo_fun' - Shell builtins" {
  default_output="$(echo 'lalala')";
  run sudo_fun echo 'lalala';
  [ "${status}" -eq 0 ];
  [[ "${output}" =~ "Builtin" ]];
  [[ "${output}" =~ "${default_output}" ]];
}

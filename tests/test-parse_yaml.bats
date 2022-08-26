#!/usr/bin/env bats

function setup () {
  source lib/which_bin.sh
  source lib/parse_yaml.sh
}

@test "'parse_yaml' - missing key on list" {
  run __parse_yaml_python tests/test_data.yaml global sample_input 1 property3;
  [ "${status}" -eq 0 ];
  [ "${output}" = '' ];
  run __parse_yaml_ruby tests/test_data.yaml global sample_input 1 property3;
  [ "${status}" -eq 0 ];
  [ "${output}" = '' ];
  run __parse_yaml_yq tests/test_data.yaml global sample_input 1 property3;
  [ "${status}" -eq 0 ];
  [ "${output}" = '' ];
}

@test "'parse_yaml' - File does not exist" {
  run parse_yaml xtest;
  [ "${status}" -eq 1 ];
  [ "${output}" = "Error: file 'xtest' does not exist" ];
}

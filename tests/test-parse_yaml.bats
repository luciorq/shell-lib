#!/usr/bin/env bats

function setup () {
  source lib/which_bin.sh
  source lib/parse_yaml.sh
  source lib/exit_fun.sh
}

@test "'parse_yaml' - missing key on list - py" {
  local py_bin;
  py_bin="$(which_bin python)";
  if [[ -z ${py_bin} ]]; then
    py_bin="$(which_bin python3)";
  fi

  # TODO: test if module is installed
  # + 'Python {yaml} module is not installed.'
  local module_res;
  module_res=$("${py_bin}" -c 'import yaml' 2> /dev/null);

  if [ $? -eq 1 ]; then
    run __parse_yaml_python tests/test_data.yaml global sample_input 1 property3;
    [ "${status}" -eq 1 ];
    [[ "${output}" =~ 'Python {yaml} module is not installed.' ]];
    return 0;
  fi

  run __parse_yaml_python tests/test_data.yaml global sample_input 1 property3;
  [ "${status}" -eq 0 ];
  [ "${output}" = '' ];
}

@test "'parse_yaml' - missing key on list - ruby" {
  run __parse_yaml_ruby tests/test_data.yaml global sample_input 1 property3;
  [ "${status}" -eq 0 ];
  [ "${output}" = '' ];
}

@test "'parse_yaml' - missing key on list - yq" {
  run __parse_yaml_yq tests/test_data.yaml global sample_input 1 property3;
  [ "${status}" -eq 0 ];
  [ "${output}" = '' ];
}

@test "'parse_yaml' - File does not exist" {
  run parse_yaml xtest;
  [ "${status}" -eq 1 ];
  [[ ${output} =~ "Error: File 'xtest' does not exist" ]];
}

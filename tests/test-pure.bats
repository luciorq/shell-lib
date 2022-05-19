#!/usr/bin/env bats

function setup () {
  source dirname_pure.sh;
  source cat_pure.sh;
  source head_pure.sh;
  source sleep_pure.sh;
}

@test "'dirname_pure' - Compare with GNU dirname" {
  dirname_res="$(dirname .)";
  run dirname_pure .;
  [ "${status}" -eq 0 ];
  [ "${output}" = "${dirname_res}" ];

  dirname_res="$(dirname ~)";
  run dirname_pure ~;
  [ "${status}" -eq 0 ];
  [ "${output}" = "${dirname_res}" ];

  dirname_res="$(dirname tests)";
  run dirname_pure tests;
  [ "${status}" -eq 0 ];
  [ "${output}" = "${dirname_res}" ];

  dirname_res="$(dirname "${HOME}")";
  run dirname_pure "${HOME}";
  [ "${status}" -eq 0 ];
  [ "${output}" = "${dirname_res}" ];
}

@test "'cat_pure' - Compare with GNU cat" {
  cat_res="$(cat tests/test_data.yaml)";
  run cat_pure tests/test_data.yaml;
  [ "${status}" -eq 0 ];
  [ "${output}" = "${cat_res}" ];
}

@test "'head_pure' - Compare with GNU head" {
  head_res="$(head -n 4 tests/test_data.yaml)";
  run head_pure 4 tests/test_data.yaml;
  [ "${status}" -eq 0 ];
  [ "${output}" = "${head_res}" ];
}

@test "'sleep_pure' - Compare with GNU sleep" {
  default_res="$(sleep 0.2)";
  run sleep_pure 0.2;
  [ "${status}" -eq 0 ];
  [ "${output}" = "${default_res}" ];
}

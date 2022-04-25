#!/usr/bin/env bash

source exit_fun.sh

function test_exit () {
  builtin echo "Normal output";
  exit_fun "${1}";

  builtin echo "Output that should not be printed";
}

test_exit "This command failed";

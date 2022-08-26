#!/usr/bin/env bash

function pure::cat () {
  cat_pure "${@}";
  return 0;
}

function pure::head () {
  head_pure "${@}";
  return 0;
}

#!/usr/bin/env bash

function pure_cat () {
  cat_pure "${@}";
  return 0;
}

function pure_head () {
  head_pure "${@}";
  return 0;
}

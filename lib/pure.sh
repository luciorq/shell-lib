#!/usr/bin/env bash

function pure_cat () {
  cat_pure "${@:-}";
  \builtin return 0;
}

function pure_head () {
  head_pure "${@:-}";
  \builtin return 0;
}

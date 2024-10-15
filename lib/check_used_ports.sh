#!/usr/bin/env bash

# Retrieve ports where programs are listening to
function check_used_ports () {
  builtin local ss_bin;
  builtin local tr_bin;
  builtin local cut_bin;
  builtin local rev_bin;
  ss_bin="$(require 'ss')";
  grep_bin="$(require 'grep')";
  tr_bin="$(require 'tr')";
  cut_bin="$(require 'cut')";
  rev_bin="$(require 'rev')";
  if [[ -z ${ss_bin} ]] || [[ -z ${grep_bin} ]] || [[ -z ${tr_bin} ]] \
    || [[ -z ${cut_bin} ]] || [[ -z ${rev_bin} ]]; then
    return 1;
  fi
  "${ss_bin}" -tulpn \
    | "${grep_bin}" LISTEN \
    | LC_COLLATE=C "${tr_bin}" -s " " \
    | "${cut_bin}" -d " " -f5 \
    | "${rev_bin}" \
    | "${cut_bin}" -d ":" -f1 \
    | "${rev_bin}";
  return 0;
}

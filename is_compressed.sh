#!/usr/bin/env bash

function is_compressed () {
  local input_file;
  local is_zip_var;
  local file_bin;
  input_file="${1}";
  file_bin="$(which_bin 'file')";
  res_txt="$("${file_bin}" -b --mime-type "${input_file}")";
  if [[ ${res_txt} == "application/gzip" ]]; then
    is_zip_var='true';
  else
    is_zip_var='false';
  fi
  builtin echo -ne "${is_zip_var}";
  return 0;
}

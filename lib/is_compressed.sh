#!/usr/bin/env bash

function is_compressed () {
  \builtin local input_file;
  \builtin local is_zip_var;
  \builtin local file_bin;
  input_file="${1:-}";
  file_bin="$(which_bin 'file')";
  # res_txt="$("${file_bin}" -b --mime-type "${input_file}")";
  res_txt="$("${file_bin}" -b "${input_file}")";
  if [[ ${res_txt} =~ "compressed" ]]; then
    is_zip_var='true';
  else
    is_zip_var='false';
  fi
  \builtin echo -ne "${is_zip_var}";
  \builtin return 0;
}

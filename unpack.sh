#!/usr/bin/env bash

# deb file module for unpack
function unpack_deb () {
  local deb_path dir_output deb_data_path i;
  local rm_bin cp_bin mkdir_bin ar_bin;
  deb_path="$1";
  dir_output="$2";
  rm_bin=$(which_bin rm);
  cp_bin=$(which_bin cp);
  mkdir_bin=$(which_bin mkdir);
  ar_bin=$(which_bin ar);
  # replace x for xv for verbose
  "${mkdir_bin}" -p "${dir_output}/deb"
  "${ar_bin}" --output="${dir_output}/deb" x "${deb_path}";
  deb_data_path=$(realpath "${dir_output}"/deb/dat*);
  unpack "${deb_data_path}" "${dir_output}";
  "${rm_bin}" -rf "${dir_output}/deb"
  mapfile -t content_dirs < <(ls "${dir_output}")
  for i in "${content_dirs[@]}"; do
    if [[ -d "${dir_output}/${i}" ]]; then
      "${cp_bin}" -r "${dir_output}/${i}"/* "${dir_output}";
      "${rm_bin}" -rf "${dir_output:?}/${i}";
    fi
  done
}

# Unpack compressed files to directory
function unpack () {
  function unpack_usage () {
    builtin echo >&2 -ne "unpack: <ZIP_FILE> [<OUTPUT_DIR>]\n";
  }
  if [[ $# -eq 0 ]]; then unpack_usage; unset unpack_usage; return 1; fi
  unset unpack_usage;
  local zip_path;
  local dir_output;
  local output_file_path;
  local rm_bin cp_bin mkdir_bin tar_bin;
  zip_path="$1";
  dir_output="$2";
  rm_bin="$(which_bin 'rm')";
  cp_bin="$(which_bin 'cp')";
  mkdir_bin="$(which_bin 'mkdir')";
  tar_bin="$(which_bin 'tar')";

  if [[ -z ${dir_output} ]]; then
    dir_output="$(realpath ./)";
  fi

  output_file_path="${dir_output}/$(basename "${zip_path}")";

  "${mkdir_bin}" -p "${dir_output}";

  if [[ -n ${zip_path} && -f ${zip_path} ]]; then
    case "${zip_path}" in
      *.tar.gz)   "${tar_bin}" -C "${dir_output}" -xzf "${zip_path}"         ;;
      *.tgz)      "${tar_bin}" -C "${dir_output}" -xzf "${zip_path}"         ;;
      *.tar.xz)   "${tar_bin}" -C "${dir_output}" -xJf "${zip_path}"         ;;
      *.txz)      "${tar_bin}" -C "${dir_output}" -xJf "${zip_path}"         ;;
      *.tar.bz2)  "${tar_bin}" -C "${dir_output}" -xjf "${zip_path}"         ;;
      *.tbz2)     "${tar_bin}" -C "${dir_output}" -xjf "${zip_path}"         ;;
      *.bz2)      "${tar_bin}" -C "${dir_output}" -xjf "${zip_path}"         ;;
      *.zip)      unzip -qq -o "${zip_path}" -d "${dir_output}"              ;;
      *.gz)       gzip -q -dkc < "${zip_path}" > "${output_file_path/.gz/}"  ;;
      *.deb)      unpack_deb "${zip_path}" "${dir_output}"                   ;;
      *)
        if [[ $(is_compressed "${zip_path}") == true ]]; then
          "${tar_bin}" -C "${dir_output}" -xf "${zip_path}";
        else
          "${cp_bin}" -r "${zip_path}" "${dir_output}"/ ;
        fi
      ;;
    esac
  else
    exit_fun "'${zip_path}' is not a valid file";
    return 1;
  fi
}

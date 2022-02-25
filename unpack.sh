#!/bin/env bash

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
    echo "unpack: <ZIP_FILE> [<OUTPUT_DIR>]" 1>&2;
  }
  if [[ $# -eq 0 ]]; then unpack_usage; unset unpack_usage; return 1; fi
  unset unpack_usage;
  local zip_path dir_output;
  local rm_bin cp_bin mkdir_bin tar_bin;
  zip_path="$1";
  dir_output="$2";
  rm_bin="$(which_bin rm)";
  cp_bin="$(which_bin cp)";
  mkdir_bin="$(which_bin mkdir)";
  tar_bin="$(which_bin tar)";

  if [[ ! -d "${dir_output}" ]]; then
    dir_output="$(realpath ./)";
  fi

  if [[ ! -d "${dir_output}" && ! -f "${dir_output}" ]]; then
    "${mkdir_bin}" -p "${dir_output}";
  fi

  if [[ -n "${zip_path}" && -f "${zip_path}" ]]; then
    case "${zip_path}" in
      *.tar.gz)   "${tar_bin}" -C "${dir_output}" -xzf "${zip_path}"    ;;
      *.tgz)      "${tar_bin}" -C "${dir_output}" -xzf "${zip_path}"    ;;
      *.tar.xz)   "${tar_bin}" -C "${dir_output}" -xJf "${zip_path}"    ;;
      *.txz)      "${tar_bin}" -C "${dir_output}" -xJf "${zip_path}"    ;;
      *.tar.bz2)  "${tar_bin}" -C "${dir_output}" -xjf "${zip_path}"    ;;
      *.tbz2)     "${tar_bin}" -C "${dir_output}" -xjf "${zip_path}"    ;;
      *.bz2)      "${tar_bin}" -C "${dir_output}" -xjf "${zip_path}"    ;;
      *.zip)      unzip -o "${zip_path}" -d "${dir_output}"             ;;
      *.gz)       gzip -q -r -dkc < "${zip_path}" > "${dir_output}"     ;;
      *.deb)      unpack_deb "${zip_path}" "${dir_output}"              ;;
      *)          "${cp_bin}" -r "${zip_path}" "${dir_output}"/         ;;
    esac
  else
    echo -ne "'${zip_path}' is not a valid file.\n";
    return 1;
  fi
}

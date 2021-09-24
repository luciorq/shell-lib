#!/bin/env bash

# deb file module for unpack
function unpack_deb () {
  local deb_path dir_output deb_data_path i
  deb_path="$1"
  dir_output="$2"
  # replace x for xv for verbose
  mkdir -p "${dir_output}/deb"
  ar --output="${dir_output}/deb" x "${deb_path}"
  deb_data_path=$(realpath "${dir_output}"/deb/dat*)
  unpack "${deb_data_path}" "${dir_output}"
  rm -rf "${dir_output}/deb"
  mapfile -t content_dirs < <(ls "${dir_output}")
  for i in "${content_dirs[@]}"; do
    if [[ -d "${dir_output}/${i}" ]]; then
      cp -r "${dir_output}/${i}"/* "${dir_output}";
      rm -rf "${dir_output:?}/${i}";
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
  local zip_path dir_output
  zip_path="$1"
  dir_output="$2"
  if [[ "${dir_output}" == "" ]]; then
    dir_output=$(realpath .);
  fi
  if [[ ! -d "${dir_output}" && ! -f "${dir_output}" ]]; then
    mkdir -p "${dir_output}";
  fi
  if [[ -n "${zip_path}" && -f "${zip_path}" ]]; then
    case "${zip_path}" in
      *.tar.gz)   tar -C "${dir_output}" -xzf "${zip_path}"         ;;
      *.tgz)      tar -C "${dir_output}" -xzf "${zip_path}"         ;;
      *.tar.xz)   tar -C "${dir_output}" -xJf "${zip_path}"         ;;
      *.txz)      tar -C "${dir_output}" -xJf "${zip_path}"         ;;
      *.tar.bz2)  tar -C "${dir_output}" -xjf "${zip_path}"         ;;
      *.tbz2)     tar -C "${dir_output}" -xjf "${zip_path}"         ;;
      *.bz2)      tar -C "${dir_output}" -xjf "${zip_path}"         ;;
      *.zip)      unzip -o "${zip_path}" -d "${dir_output}"         ;;
      *.gz)       gzip -q -r -dkc < "${zip_path}" > "${dir_output}" ;;
      *.deb)      unpack_deb "${zip_path}" "${dir_output}"          ;;
      *)          cp -R "${zip_path}" "${dir_output}/"              ;;
    esac
  else
    echo "'${zip_path}' is not a valid file";
  fi
}



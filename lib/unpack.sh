#!/usr/bin/env bash

# deb file module for unpack
function __unpack_deb () {
  local deb_path dir_output deb_data_path _i;
  local rm_bin cp_bin mkdir_bin ar_bin;
  local realpath_bin;
  local ls_bin;
  deb_path="${1}";
  dir_output="${2}";
  rm_bin="$(which_bin 'rm')";
  ls_bin="$(which_bin 'ls')";
  cp_bin="$(which_bin 'cp')";
  mkdir_bin="$(which_bin 'mkdir')";
  ar_bin="$(which_bin 'ar')";
  realpath_bin="$(which_bin 'realpath')";
  "${mkdir_bin}" -p "${dir_output}/deb";
  # replace x for xv for verbose
  "${ar_bin}" --output="${dir_output}/deb" x "${deb_path}";
  deb_data_path=$("${realpath_bin}" "${dir_output}"/deb/dat*);
  unpack "${deb_data_path}" "${dir_output}";
  "${rm_bin}" -rf "${dir_output}/deb"
  builtin mapfile -t content_dirs < <("${ls_bin}" "${dir_output}")
  for _i in "${content_dirs[@]}"; do
    if [[ -d "${dir_output}/${_i}" ]]; then
      "${cp_bin}" -r "${dir_output}/${_i}"/* "${dir_output}";
      "${rm_bin}" -rf "${dir_output:?}/${_i}";
    fi
  done
  return 0;
}

# Unpack compressed files to directory
function unpack () {
  local _usage;
  function _usage () {
    builtin echo >&2 -ne "Usage: ${0} <ZIP_FILE> [<OUTPUT_DIR>]\n";
  }
  if [[ ${#} -eq 0 ]]; then _usage; unset _usage; return 1; fi
  unset _usage;
  local zip_path;
  local dir_output;
  local output_file_path;
  local rm_bin;
  local cp_bin;
  local mkdir_bin;
  local tar_bin;
  local realpath_bin;
  local basename_bin;
  local unzip_bin;
  local gzip_bin;
  local unrar_bin;
  zip_path="${1}";
  dir_output="${2}";
  rm_bin="$(which_bin 'rm')";
  cp_bin="$(which_bin 'cp')";
  mkdir_bin="$(which_bin 'mkdir')";
  tar_bin="$(which_bin 'tar')";
  realpath_bin="$(which_bin 'realpath')";
  basename_bin="$(which_bin 'basename')";
  unzip_bin="$(which_bin 'unzip')";
  gzip_bin="$(which_bin 'gzip')";
  unrar_bin="$(which_bin 'unrar')";
  if [[ -z ${dir_output} ]]; then
    dir_output="$("${realpath_bin}" ./)";
  fi

  output_file_path="${dir_output}/$("${basename_bin}" "${zip_path}")";

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
      *.zip)      "${unzip_bin}" -qq -o "${zip_path}" -d "${dir_output}"     ;;
      *.rar)      "${unrar_bin}" x -y "${zip_path}" "${dir_output}"             ;;
      *.gz)
        "${gzip_bin}" -q -dkc < "${zip_path}" > "${output_file_path/.gz/}";
      ;;
      *.deb)
        __unpack_deb "${zip_path}" "${dir_output}";
      ;;
      *)
        if [[ $(is_compressed "${zip_path}") == true ]]; then
          "${tar_bin}" -C "${dir_output}" -xf "${zip_path}";
        else
          "${cp_bin}" -r "${zip_path}" "${dir_output}"/;
        fi
      ;;
    esac
  else
    exit_fun "'${zip_path}' is not a valid file";
    return 1;
  fi
  return 0;
}

#!/usr/bin/env bash

# Main ------------------------------------------------------------------------
# Install Apps defined in a configuration YAML file.
function install_apps () {
  local _usage="usage: $0 [--user|--system]";
  local args_arr _arg;
  local install_type;
  local apps_length;
  local apps_yaml_list;
  local app_num_arr;
  local app_num;
  declare -a args_arr=( ${@} );
  if [[ -z ${args_arr[@]} ]]; then
    install_type='--user';
  fi
  for _arg in ${args_arr[@]}; do
    if [[ ${_arg} == --system ]]; then
      install_type='--system';
    elif [[ ${_arg} == --user ]]; then
      install_type='--user';
    fi
  done

  apps_length="$(get_config apps apps | grep -c '^name:')";
  declare -a app_num_arr=( $( seq 0 $(( ${apps_length} - 1 ))) );

  for app_num in ${app_num_arr[@]}; do
    echo "Installing App: '${app_num}'";
    __install_app "${install_type}" "${app_num}";
  done
}

# Utils -----------------------------------------------------------------------
function __install_path () {
  local base_path;
  local install_type;
  install_type="${1}";
  if [[ -z ${install_type} ]]; then
    install_type='--user';
  fi
  if [[ ${install_type} == --system ]]; then
    base_path="/opt/apps";
  elif [[ ${install_type} == --user ]]; then
    base_path="${HOME}/.local/opt/apps";
  fi
  builtin echo -ne "${base_path}";
  return 0;
}

function __get_gh_latest_release () {
  local repo;
  local release_url;
  local latest_version;
  repo="$1";
  release_url=$(
    curl -fsSL -I -o /dev/null -w %{url_effective} \
      "https://github.com/${repo}/releases/latest"
  );
  latest_version=$(echo "${release_url}" | sed "s|.*/tag/||");
  builtin echo -ne "${latest_version}";
  return 0;
}

# Install apps utils ----------------------------------------------------------

# Install app from downloadable tarball source code
function __install_app_source () {
  local install_path;
  local tarball_name;
  local get_url;
  local dl_path;
  local build_arr;
  local build_path;
  local rm_bin;
  local ls_bin;
  local nproc_bin;
  local num_threads;
  rm_bin="$(which_bin 'rm')";
  ls_bin="$(which_bin 'ls')";
  nproc_bin="$(which_bin 'nproc')";
  if [[ -n ${nproc_bin} ]]; then
    num_threads=$("${nproc_bin}");
    if [[ ${num_threads} -gt 8 ]]; then
      num_threads=8;
    fi
  else
    num_threads=8;
  fi
  install_path="${1}";
  tarball_name="${2}";
  get_url="${3}";
  dl_path="$(create_temp 'install_app')";
  download "${get_url}" "${dl_path}";
  unpack "${dl_path}/${tarball_name}" "${dl_path}";
  "${rm_bin}" -rf "${dl_path}/${tarball_name}";
  declare -a build_arr=( $("${ls_bin}" -A1 "${dl_path}") );
  build_path="${dl_path}/${build_arr[0]}"
  # make -C "${build_path}/bash-${build_version}" configure -j ${num_threads};
  (cd "${build_path}" && ./configure --prefix="${install_path}");
  make -C "${build_path}" -j ${num_threads};
  make -C "${build_path}" install -j ${num_threads};
  "${rm_bin}" -rf "${build_path}";
  return 0;
}

# Install app from downloadable tarball binary
function __install_app_binary () {
  local install_path;
  local tarball_name;
  local get_url;
  local dl_path;
  local rm_bin;
  rm_bin="$(which_bin 'rm')";
  install_path="${1}";
  tarball_name="${2}";
  get_url="${3}";
  dl_path="$(create_temp 'install_app')";
  download "${get_url}" "${dl_path}";
  unpack "${dl_path}/${tarball_name}" "${install_path}";
  "${rm_bin}" -rf "${dl_path}/${tarball_name}";
  return 0;
}

# Install rust binaries from cargo
function __install_app_cargo () {
  local cargo_bin;
  local install_path;
  local app_name;
  local app_url;
  local cargo_type;
  cargo_bin=$(which_bin 'cargo');
  if [[ -z ${cargo_bin} ]]; then
    builtin echo -ne "'cargo' is not available for installing rust apps.\n";
    return 1;
  fi
  install_path="${1}";
  app_name="${2}";
  get_url="${3}";
  if [[ -n ${get_url} ]]; then
    app_name="--git ${get_url}";
  fi
  "${cargo_bin}" install \
    --all-features \
    --root "${install_path}" \
    ${app_name};
  return 0;
}

# Install App -----------------------------------------------------------------

# Install Application to a local user path or system wide
function __install_app () {
  # Variable declaration ------------------------------------------------------
  local _usage="usage: $0 [--user|--system] <APP_NUM>";
  local sed_bin rm_bin cp_bin mkdir_bin ln_bin chmod_bin;
  local args_arr last_arg _arg;
  local install_type;
  local app_num;
  local link_inst_path;
  local app_name;
  local app_version;
  local app_repo;
  local app_url;
  local base_url get_url;
  local app_type;
  local tarball_version;
  local tarball_name;
  local exec_path_arr;
  local exec_path;
  local extra_cmd_arr;
  local extra_cmd;
  local app_link;
  local dl_path lib_path;
  local install_path;
  local missing_install;

  # Check available tools -----------------------------------------------------
  sed_bin=$(which_bin 'gsed');
  if [[ -z ${sed_bin} ]]; then
    sed_bin="$(require 'sed')";
  fi
  rm_bin="$(require 'rm')";
  cp_bin="$(require 'cp')";
  mkdir_bin="$(require 'mkdir')";
  ln_bin="$(require 'ln')";

  # Argument parsing -- -------------------------------------------------------
  declare -a args_arr=( ${@} );
  last_arg="${args_arr[${#args_arr[@]} - 1]}";
  if [[ -z ${last_arg} ]]; then
    last_arg='0';
    install_type='--user';
  fi
  case ${last_arg} in
    0)        app_num='0'                               ;;
    --user)   app_num='0'; install_type='--user'        ;;
    --system) app_num='0'; install_type='--system'      ;;
    *)        app_num="${last_arg}"     ;;
  esac
  link_inst_path='';
  for _arg in ${args_arr[@]}; do
    if [[ ${_arg} == --system ]]; then
      link_inst_path="/usr/local/bin";
      install_type='--system';
    elif [[ ${_arg} == --user ]]; then
      link_inst_path="${HOME}/.local/bin";
      install_type='--user';
    fi
  done

  # YAML Argument parsing -----------------------------------------------------
  app_name=$(
    get_config apps apps ${app_num} name 2> /dev/null || builtin echo -ne ''
  )
  if [[ -z ${app_name} || ${app_name} == null ]]; then
    builtin echo >&2 -ne "'name' not fount for '${app_num}'.\n";
    builtin echo >&2 -ne "Each element of the app list need a 'name' value.\n";
    return 1;
  fi
  app_version=$(
    get_config apps apps ${app_num} version 2> /dev/null || builtin echo -ne ''
  )
  if [[ -z ${app_version} || ${app_version} == null ]]; then
    app_version='latest';
  fi
  app_repo=$(
    get_config apps apps ${app_num} repo 2> /dev/null || builtin echo -ne ''
  )
  if [[ ${app_repo} == null ]]; then
    app_repo='';
  fi
  if [[ ${app_version} == latest && -n ${app_repo} ]]; then
    app_version=$(__get_gh_latest_release "${app_repo}");
  fi
  tarball_version="${app_version#v*}";

  app_url=$(
    get_config apps apps ${app_num} url 2> /dev/null || builtin echo -ne ''
  )

  if [[ ${app_url} == null ]]; then
    app_url='';
  fi
  app_url=$(
    builtin echo -ne \
      $(get_config apps apps ${app_num} url 2> /dev/null \
      || builtin echo -ne '') \
      | sed "s|{[ ]*name[ ]*}|${app_name}|g" \
      | sed "s|{[ ]*version[ ]*}|${tarball_version}|g"
  )
  if [[ ${app_url} == null ]]; then
    app_url='';
  fi

  app_type=$(
    builtin echo -ne \
      $(get_config apps apps ${app_num} type 2> /dev/null \
      || builtin echo -ne '')
  )
  if [[ ${app_type} == null ]]; then
    app_type='binary';
  fi
  if [[ -n ${app_repo} && -z ${app_url} ]]; then
    app_type="${app_type}_github";
  fi

  tarball_name=$(
    builtin echo -ne \
      $(get_config apps apps ${app_num} tarball 2> /dev/null \
      || builtin echo -ne '') \
      | sed "s|{[ ]*name[ ]*}|${app_name}|g" \
      | sed "s|{[ ]*version[ ]*}|${tarball_version}|g"
  )

  if [[ -n ${app_url} ]]; then
    if [[ ${tarball_name} == null || -z ${tarball_name} ]]; then
      tarball_name="$(basename ${app_url})";
    fi
  else
    tarball_name='';
  fi
  declare -a exec_path_arr=(
    $(builtin echo -ne \
      $(get_config apps apps ${app_num} exec_path 2> /dev/null \
        || builtin echo -ne '') \
        | sed "s|{[ ]*name[ ]*}|${app_name}|g" \
        | sed "s|{[ ]*version[ ]*}|${tarball_version}|g" \
        | sed "s|{[ ]*repo[ ]*}|${app_repo}|g" \
        | sed "s|{[ ]*tarball[ ]*}|${tarball_name}|g" \
        | sed "s|{[ ]*install_path[ ]*}|${install_path}|g" \
        | sed "s|{[ ]*lib_path[ ]*}|${lib_path}|g"
    )
  )

  if [[ ${exec_path_arr[@]} == null ]]; then
    exec_path_arr='';
  fi
  if [[ -z ${exec_path_arr[@]} ]]; then
    exec_path_arr="${app_name}";
  fi
  app_link=$(
    get_config apps apps ${app_num} link 2> /dev/null || builtin echo -ne ''
  )
  # Argument checking ---------------------------------------------------------
  if [[ -z ${app_link} || ${app_link} == null ]]; then
    app_link='true';
  elif [[ ${app_link} == no || \
          ${app_link} == false || \
          ${app_link} == FALSE || \
          ${app_link} == False ]]; then
   app_link='false';
  elif [[ ${app_link} == yes || \
          ${app_link} == true || \
          ${app_link} == TRUE || \
          ${app_link} == True ]]; then
   app_link='true';
  fi

  case ${app_type} in
    source_github)
      base_url="https://github.com/${app_repo}/releases/download/${app_version}";
      get_url="${base_url}/${tarball_name}";
      app_type="source";
    ;;
    binary_github)
      base_url="https://github.com/${app_repo}/releases/download/${app_version}";
      get_url="${base_url}/${tarball_name}";
      app_type="binary";
    ;;
    cargo_github)
      base_url='';
      get_url="https://github.com/${app_repo}";
      app_type="cargo";
    ;;

    *)
      base_url='';
      get_url="${app_url}";
  esac

  lib_path="$(__install_path ${install_type})";
  install_path="${lib_path}/${app_name}/${app_version}";
  missing_install='false';
  for exec_path in ${exec_path_arr[@]}; do
    if [[ ! -f ${install_path}/${exec_path} ]]; then
      missing_install='true';
    fi
  done
  if [[ ${app_type} == binary && ${missing_install} == false ]]; then
    return 0;
  fi

  # Main ----------------------------------------------------------------------
  #echo $dl_path
  #echo $get_url
  #echo $lib_path
  #echo $install_path
  #echo "${link_inst_path}/$(basename ${exec_path_arr[0]})"

  if [[ ! -d ${install_path} ]]; then
    "${mkdir_bin}" -p "${install_path}";
  fi

  case ${app_type} in
    source)
      __install_app_source "${install_path}" "${tarball_name}" "${get_url}";
    ;;
    binary)
      __install_app_binary "${install_path}" "${tarball_name}" "${get_url}";
    ;;
    cargo)
      if [[ -z ${get_url} && -n ${app_repo} ]]; then
        get_url="https://github.com/${app_repo}";
      fi
      __install_app_cargo "${install_path}" "${app_name}" "${get_url}";
    ;;
    *)
      builtin echo >&2 \
        -ne "Error: Unknown installation type: '${app_type}'.\n";
      return 1;
    ;;
  esac

  chmod_bin="$(which_bin 'chmod')";
  "${chmod_bin}" +x "${install_path}/${exec_path_arr[0]}";
  if [[ ${app_link} == true ]]; then
    for exec_path in ${exec_path_arr[@]}; do
      if [[ -f ${link_inst_path}/$(basename ${exec_path}) ]]; then
        "${rm_bin}" "${link_inst_path}/$(basename ${exec_path})";
      fi
      "${chmod_bin}" +x "${install_path}/${exec_path}";
      "${ln_bin}" -sf \
        "${install_path}/${exec_path}" \
        "${link_inst_path}/$(basename ${exec_path})";
    done
  fi

  extra_cmd=$(builtin echo -ne $(get_config apps apps ${app_num} extra_cmd 2> /dev/null builtin echo -ne '') \
        | sed "s|{[ ]*name[ ]*}|${app_name}|g" \
        | sed "s|{[ ]*version[ ]*}|${tarball_version}|g" \
        | sed "s|{[ ]*repo[ ]*}|${app_repo}|g" \
        | sed "s|{[ ]*tarball[ ]*}|${tarball_name}|g" \
        | sed "s|{[ ]*install_path[ ]*}|${link_inst_path}|g" \
        | sed "s|{[ ]*lib_path[ ]*}|${install_path}|g" \
        | sed "s|{[ ]*exec_path[ ]*}|${exec_path_arr[0]}|g"
  )
  if [[ ${extra_cmd} == null ]]; then
    extra_cmd='';
  fi
  if [[ -n ${extra_cmd} ]]; then
    builtin eval $(builtin echo "${extra_cmd}");
  fi
  builtin echo -ne "App: '${app_name}' (${app_version}) installed succesfully\n";
  return 0;
}


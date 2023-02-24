#!/usr/bin/env bash

# Main ------------------------------------------------------------------------
# Install Apps defined in a configuration YAML file.
function install_apps () {
  local _usage="usage: $0 [--user|--system]";
  local _arg;
  local install_type;
  local apps_length;
  local app_num_arr;
  local app_num;
  if [[ ${#} -eq 0 ]]; then
    install_type='--user';
  fi
  for _arg in "${@}"; do
    if [[ ${_arg} == --system ]]; then
      install_type='--system';
    elif [[ ${_arg} == --user ]]; then
      install_type='--user';
    fi
  done

  apps_length="$(get_config apps apps | grep -c '^name:')";
  builtin mapfile -t app_num_arr < <(
    seq 0 $(( apps_length - 1 ))
  );

  for app_num in "${app_num_arr[@]}"; do
    builtin echo -ne "Installing App: '${app_num}':\n";
    __install_app "${install_type}" "${app_num}";
  done

  builtin echo -ne "Completed 'install_apps'\n";
  return 0;
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
    local curl_bin;
    repo="${1}";
    curl_bin="$(require 'curl')";
    release_url="$(
      "${curl_bin}" -fsSL \
        --insecure -I -o /dev/null -w '%{url_effective}' \
        "https://github.com/${repo}/releases/latest"
    )";
    latest_version="${release_url//http*\/tag\//}";
    latest_version="${latest_version//http*\/releases/}";
    builtin echo -ne "${latest_version}";
    return 0;
  }

  function __get_gh_latest_tag () {
    local repo;
    local latest_tag;
    local tag_arr;
    local tag_sort_arr;
    local final_tag;
    local cat_bin;
    local sed_bin;
    local grep_bin;
    local curl_bin;
    repo="${1}";
    grep_bin="$(require 'grep')";
    sed_bin="$(require 'sed')";
    cat_bin="$(which_bin 'cat')";
    curl_bin="$(which_bin 'curl')";
    latest_tag="$(
      "${curl_bin}" -fsSL \
        --insecure \
        "https://api.github.com/repos/${repo}/tags"
    )";
    builtin mapfile -t latest_tag_arr < <(
      builtin echo -ne "${latest_tag}" \
        | "${grep_bin}" '"name": ' \
        | "${grep_bin}" -v "\-rc\|\-beta\|\-alpha\|devel"
    )
    builtin mapfile -t tag_arr < <(
      builtin echo "${latest_tag_arr[@]}" \
        | "${sed_bin}" 's|\"name\":||g' \
        | sed 's|\"||g' \
        | sed 's|\\s+||g' \
        | sed 's|\,||g'
    )
    builtin mapfile -t tag_sort_arr < <(
      "${cat_bin}" <(
        for _i in ${tag_arr[@]}; do builtin echo -ne "${_i}\n"; done;
      ) \
        | grep '^v*[0-9]' \
        | sort -rV
    )
    final_tag="${tag_sort_arr[0]}";
    builtin echo -ne "${final_tag}\n";
    return 0;
  }

  # Retrieve app_num from app_namw
  function __get_app_num_from_app_name () {
    local input_name;
    local apps_length;
    local _app_num;
    local app_num_arr;
    local app_num_res;
    local app_name;
    local seq_bin;
    seq_bin="$(require 'seq')";
    input_name="${1}";
    apps_length="$(get_config apps apps | grep -c '^name:')";
    builtin mapfile -t app_num_arr < <(
      "${seq_bin}" 0 $(( apps_length - 1 ))
    );
    app_num_res='';
    #echo "${input_name}";
    for _app_num in "${app_num_arr[@]}"; do
      app_name="$(get_config apps apps "${_app_num}" name 2> /dev/null \
        || builtin echo -ne '')";
      #echo "${app_name}";
      if [[ ${input_name} == "${app_name}" && -n ${input_name} && -n ${app_name} ]]; then
        app_num_res="${_app_num}";
      fi
    done
    if [[ -z ${app_num_res} ]]; then
      builtin echo -ne "${input_name}";
    else
      builtin echo -ne "${app_num_res}";
    fi
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
    local make_bin;
    local num_threads;
    install_path="${1}";
    tarball_name="${2}";
    get_url="${3}";
    rm_bin="$(which_bin 'rm')";
    ls_bin="$(which_bin 'ls')";
    make_bin="$(which_bin 'gmake')";
    if [[ -z ${make_bin} ]]; then
      make_bin="$(require 'make')";
    fi
    num_threads="$(get_nthreads 8)";
    dl_path="$(create_temp 'install_app')";
    download "${get_url}" "${dl_path}";
    unpack "${dl_path}/${tarball_name}" "${dl_path}";
    "${rm_bin}" -rf "${dl_path}/${tarball_name}";
    builtin mapfile -t build_arr < <(
      "${ls_bin}" -A1 "${dl_path}"
    );
    build_path="${dl_path}/${build_arr[0]}";
    # make -C "${build_path}/bash-${build_version}" configure -j ${num_threads};
    function __build_app () {
      (
        builtin cd "${build_path}" \
          || builtin return 1;
        ./configure --prefix="${install_path}";
      )
    };
    "${make_bin}" \
      -C "${build_path}" \
      -j "${num_threads}";
    "${make_bin}" \
      -C "${build_path}" install \
      -j "${num_threads}";
    "${rm_bin}" -rf "${build_path}";
    "${rm_bin}" -rf "${dl_path}";
    return 0;
  }


  # install app in a conda environment, using micromamba, if available
  function __install_app_mamba () {
    local _usage="Usage: ${0} <--user|--system> <APP_NAME> <BIN_NAME_1> [<BIN_NAME_2> ... <BIN_NAME_N>]";
    unset _usage;
    local install_path;
    local app_name;
    local install_type;
    local prefix_path;
    local envs_path;
    local link_path;
    local install_path;
    local mamba_bin;
    local mkdir_bin;
    local ln_bin;
    local chmod_bin;
    local touch_bin
    local _exec_bin;
    local exec_file;
    # local python_version;
    install_type="${1}";
    app_name="${2}";
    mamba_bin="$(which_bin 'micromamba')";
    if [[ -z ${mamba_bin} ]]; then
      mamba_bin="$(which_bin 'mamba')";
    fi
    if [[ -z ${mamba_bin} ]]; then
      mamba_bin="$(which_bin 'conda')";
    fi
    if [[ -z ${mamba_bin} ]]; then
      exit_fun '{mamba} is not available in {PATH}';
      return 1;
    fi
    mkdir_bin="$(which_bin 'mkdir')";
    ln_bin="$(which_bin 'ln')";
    chmod_bin="$(which_bin 'chmod')";
    touch_bin="$(which_bin 'touch')";

    if [[ ${install_type} == "--user" ]]; then
      prefix_path="${XDG_DATA_HOME:-${HOME}/.local/share}/conda";
      envs_path="${HOME}/.local/opt/apps/${app_name}/envs";
      install_path="${HOME}/.local/opt/apps/${app_name}/bin";
      link_path="${HOME}/.local/bin";
    elif [[ ${install_type} == "--system" ]]; then
      prefix_path="/opt/apps/conda";
      envs_path="/opt/apps/${app_name}/envs";
      install_path="/opt/apps/${app_name}/bin";
      link_path='/usr/local/bin';
    fi

    if [[ ! -d ${envs_path}/${app_name} ]]; then
      "${mamba_bin}" create \
        --yes \
        --quiet \
        --no-rc \
        --no-env \
        -c conda-forge \
        -c bioconda \
        -c defaults \
        --root-prefix "${prefix_path}" \
        --prefix "${envs_path}/${app_name}" \
        -n "${app_name}" \
        "${app_name}";
    fi

    "${mkdir_bin}" -p "${install_path}";

    # TODO: @luciorq Add link option check before creating _exec_bin file
    # TODO: @luciorq Search for mamba or conda binaries in the exec_file call
    for _exec_bin in "${@:3}"; do
      exec_file="${install_path}/${_exec_bin}";
      "${touch_bin}" "${exec_file}";
      builtin echo -ne '#!/usr/bin/env bash\n\n' > "${exec_file}";
      builtin echo \
        "${mamba_bin} run --prefix ${envs_path}/${app_name} ${_exec_bin} \"\${@}\"" \
        >> "${exec_file}";
      "${chmod_bin}" +x "${exec_file}";
      "${ln_bin}" -sf "${exec_file}" "${link_path}/${_exec_bin}";
    done
    return 0;
  }

  function __install_app_conda () {
    __install_app_mamba "${@}";
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
    "${rm_bin}" -rf "${dl_path}";
    return 0;
  }

  # Install rust binaries from cargo
  function __install_app_cargo () {
    local cargo_bin;
    local install_path;
    local app_name;
    local app_url;
    local git_var;
    cargo_bin=$(which_bin 'cargo');
    if [[ -z ${cargo_bin} ]]; then
      exit_fun "'{cargo}' is not available for installing rust apps.";
      return 1;
    fi
    install_path="${1}";
    app_name="${2}";
    get_url="${3}";

    git_var='';
    if [[ -n ${get_url} ]]; then
      git_var='--git ';
      app_name="${get_url}";
    fi
    "${cargo_bin}" install \
      --quiet \
      --all-features \
      --root "${install_path}" \
      ${git_var}${app_name};
    return 0;
  }

  # Install App -----------------------------------------------------------------

  # Install Application to a local user path or system wide
  function __install_app () {
    # Variable declaration ------------------------------------------------------
    local _usage="usage: $0 [--user|--system] <APP_NUM/APP_NAME>";
    local sed_bin rm_bin;
    # local cp_bin;
    local mkdir_bin ln_bin chmod_bin;
    local _arg;
    local install_type;
    local app_num;
    local num_regex;
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
    local _extra_cmd;
    local extra_cmd;
    local app_link;
    local dl_path lib_path;
    local install_path;
    local missing_install;
    local _link_exec;

    # Check available tools -----------------------------------------------------
    sed_bin=$(which_bin 'gsed');
    if [[ -z ${sed_bin} ]]; then
      sed_bin="$(require 'sed')";
    fi
    rm_bin="$(require 'rm')";
    # cp_bin="$(require 'cp')";
    mkdir_bin="$(require 'mkdir')";
    ln_bin="$(require 'ln')";

    # Argument parsing -- -------------------------------------------------------
    app_num="${2}";
    if [[ -z ${app_num} ]]; then
      app_num="${1}";
    fi

    # get app_num if name was input
    num_regex='^[0-9]+$';
    if ! [[ ${app_num} =~ ${num_regex} ]]; then
      app_num="$(__get_app_num_from_app_name "${app_num}")";
    fi
    if [[ -z ${app_num} ]]; then
      exit_fun "App {${app_num}} is not available."
      return 1;
    fi
    link_inst_path='';
    if [[ $# -eq 0 || $# -eq 1 ]]; then
      link_inst_path="${HOME}/.local/bin";
      install_type='--user';
    fi
    for _arg in "${@}"; do
      if [[ ${_arg} == --system ]]; then
        link_inst_path="/usr/local/bin";
        install_type='--system';
      elif [[ ${_arg} == --user ]]; then
        link_inst_path="${HOME}/.local/bin";
        install_type='--user';
      fi
    done

    # YAML Argument parsing -----------------------------------------------------
    app_name="$(
      get_config apps apps "${app_num}" name 2> /dev/null || builtin echo -ne ''
    )";
    builtin echo -ne "  --> ${app_name}\n";
    if [[ -z ${app_name} || ${app_name} == null ]]; then
      exit_fun "'name' not found for '${app_num}'.
        Each element of the app list need a 'name' value.";
      return 1;
    fi
    app_version="$(
      get_config apps apps "${app_num}" version 2> /dev/null || builtin echo -ne ''
    )";
    if [[ -z ${app_version} || ${app_version} == null ]]; then
      app_version='latest';
    fi
    app_repo="$(
      get_config apps apps "${app_num}" repo 2> /dev/null || builtin echo -ne ''
    )"
    if [[ ${app_repo} == null ]]; then
      app_repo='';
    fi
    if [[ ${app_version} == latest && -n ${app_repo} ]]; then
      app_version="$(__get_gh_latest_release "${app_repo}")";
      if [[ -z ${app_version} ]]; then
        app_version="$(__get_gh_latest_tag "${app_repo}")";
      fi
    fi
    tarball_version="${app_version#v*}";

    app_url="$(
      get_config apps apps "${app_num}" url 2> /dev/null || builtin echo -ne ''
    )";

    if [[ ${app_url} == null ]]; then
      app_url='';
    fi
    app_url="$(
      builtin echo -ne \
        "$(get_config apps apps "${app_num}" url 2> /dev/null \
        || builtin echo -ne '')" \
        | sed "s|{[ ]*name[ ]*}|${app_name}|g" \
        | sed "s|{[ ]*version[ ]*}|${tarball_version}|g"
    )";
    if [[ ${app_url} == null ]]; then
      app_url='';
    fi

    app_type="$(
      get_config apps apps "${app_num}" type 2> /dev/null \
        || builtin echo -ne ''
    )";
    if [[ ${app_type} == null || -z ${app_type} ]]; then
      app_type='binary';
    fi
    if [[ ${app_type} == 'mamba' ]]; then
      app_type='conda';
    fi
    if [[ -n ${app_repo} && -z ${app_url} ]]; then
      app_type="${app_type}_github";
    fi

    tarball_name="$(
      builtin echo -ne \
        "$(get_config apps apps "${app_num}" tarball 2> /dev/null \
        || builtin echo -ne '')" \
        | sed "s|{[ ]*name[ ]*}|${app_name}|g" \
        | sed "s|{[ ]*version[ ]*}|${tarball_version}|g"
    )"

    if [[ -n ${app_url} ]]; then
      if [[ ${tarball_name} == null || -z ${tarball_name} ]]; then
        tarball_name="$(basename "${app_url}")";
      fi
    fi
    builtin mapfile -t exec_path_arr < <(
      builtin echo -ne \
        "$(get_config apps apps "${app_num}" exec_path 2> /dev/null \
          || builtin echo -ne '')" \
          | sed "s|{[ ]*name[ ]*}|${app_name}|g" \
          | sed "s|{[ ]*version[ ]*}|${tarball_version}|g" \
          | sed "s|{[ ]*repo[ ]*}|${app_repo}|g" \
          | sed "s|{[ ]*tarball[ ]*}|${tarball_name}|g" \
          | sed "s|{[ ]*install_path[ ]*}|${install_path}|g" \
          | sed "s|{[ ]*lib_path[ ]*}|${lib_path}|g"
    )
    if [[ ${exec_path_arr[0]} == null ]]; then
      declare -a exec_path_arr=();
      unset exec_path_arr;
      exec_path_arr='';
    fi
    if [[ -z ${exec_path_arr[0]} ]]; then
      exec_path_arr="${app_name}";
    fi
    app_link="$(
      get_config apps apps "${app_num}" link 2> /dev/null || builtin echo -ne ''
    )";
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
    case "${app_type}" in
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
    lib_path="$(__install_path "${install_type}")";
    install_path="${lib_path}/${app_name}/${app_version}";
    missing_install='false';
    for exec_path in "${exec_path_arr[@]}"; do
      if [[ ! -f ${install_path}/${exec_path} ]]; then
        missing_install='true';
      fi
    done

    local skip_download_step;
    skip_download_step='false';
    local skip_link_step;
    skip_link_step='false';
    if [[ ${app_type} != cargo && ${app_type} != conda && ${missing_install} == false ]]; then
      skip_download_step='true;';
    fi

    # Main ----------------------------------------------------------------------
    if [[ ! -d ${install_path} ]]; then
      "${mkdir_bin}" -p "${install_path}";
    fi
    if [[ ${skip_download_step} == false ]]; then
    case "${app_type}" in
      source)
        __install_app_source "${install_path}" "${tarball_name}" "${get_url}";
      ;;
      binary)
        __install_app_binary "${install_path}" "${tarball_name}" "${get_url}";
      ;;
      cargo)
        __install_app_cargo "${install_path}" "${app_name}" "${get_url}";
      ;;
      conda)
        __install_app_mamba "${install_type}" "${app_name}" "${exec_path_arr[@]}";
      ;;
      *)
        exit_fun "Error: Unknown installation type: '${app_type}'.";
        return 1;
      ;;
  esac
  fi
  if [[ ! -d ${link_inst_path} ]]; then
    "${mkdir_bin}" -p "${link_inst_path}";
  fi
  if [[ ${skip_link_step} == false ]]; then
  if [[ ! ${app_type} == conda ]]; then
    chmod_bin="$(which_bin 'chmod')";
    "${chmod_bin}" +x "${install_path}/${exec_path_arr[0]}";
    if [[ ${app_link} == true ]]; then
      for exec_path in "${exec_path_arr[@]}"; do
        _link_exec="${link_inst_path}/$(basename "${exec_path}")";
        if [[ -f ${_link_exec} ]]; then
          "${rm_bin}" "${_link_exec}";
        fi
        "${chmod_bin}" +x "${install_path}/${exec_path}";
        "${ln_bin}" -sf \
          "${install_path}/${exec_path}" \
          "${link_inst_path}/$(basename "${exec_path}")";
      done
    fi
  fi
  fi
  builtin mapfile -t extra_cmd_arr < <(
    get_config apps apps "${app_num}" extra_cmd \
      2> /dev/null \
      || builtin echo -ne ''
  );
  if [[ -z ${extra_cmd_arr[0]} ]]; then
    extra_cmd_arr[0]='';
  fi
  if [[ -n ${extra_cmd_arr[0]} ]]; then
    for _extra_cmd in "${extra_cmd_arr[@]}"; do
      extra_cmd=$(builtin echo "${_extra_cmd}" \
        | sed "s|{[ ]*name[ ]*}|${app_name}|g" \
        | sed "s|{[ ]*version[ ]*}|${tarball_version}|g" \
        | sed "s|{[ ]*repo[ ]*}|${app_repo}|g" \
        | sed "s|{[ ]*tarball[ ]*}|${tarball_name}|g" \
        | sed "s|{[ ]*install_path[ ]*}|${link_inst_path}|g" \
        | sed "s|{[ ]*lib_path[ ]*}|${install_path}|g" \
        | sed "s|{[ ]*exec_path[ ]*}|${exec_path_arr[0]}|g"
      )
      echo "${extra_cmd[*]}";
      builtin eval $(echo ${extra_cmd[*]});
    done
  fi
  builtin echo -ne \
    "App: '${app_name}' (${app_version}) installed succesfully\n";
  return 0;
}

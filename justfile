prj_name := 'shell-lib'
lib_home := env_var_or_default('XDG_LIB_HOME', env_var('HOME') + '/.local/lib')
lib_path := env_var('_LOCAL_PROJECT') + '/' + prj_name
dest_dir := lib_home + '/' + prj_name

default:
  @just --choose

# integrate functions from source lib
install-separate:
  #!/usr/bin/env bash
  set -euxo pipefail
  mkdir -p {{dest_dir}}
  funs=($(ls *.sh))
  for i in ${funs[@]}; do cp {{lib_path}}/"${i}" {{dest_dir}}/; done

build:
  bashly generate

install-bundle:
  #!/usr/bin/env bash
  set -euxo pipefail


install-mac-launchers:
  #!/usr/bin/env bash
  set -euxo pipefail
  for _app in $(\ls -A1 "{{lib_path}}/inst/"*.command); do
    inst_path="/usr/local/bin/$(basename ${_app})";
    [[ -f ${inst_path} ]] && sudo rm "${inst_path}";
    chmod a+x "${_app}";
    sudo cp "${_app}" "${inst_path}";
  done


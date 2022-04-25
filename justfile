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
  #!/usr/bin/env bash
  set -euxo pipefail
  bashly generate
  # for _i in "$(\ls -A1 src/)"; do
  #  _function_name="$(basename ${_i%%.*})";
  #  bashly generate --wrap ${_function_name};
  #done
  bashly add comp script share/completions.bash --force
  bashly add comp function --force
  bashly generate --upgrade --env production --wrap "${_tool_name}"
  sed -i -e 's|exit|return|g' "${_tool_name}"
  sed -i -e 's|  set -e|  # set -e|g' "${_tool_name}"
  mv "${_tool_name}" "${_tool_name}_fun";
  # cp "inst/${_tool_name}" "${_tool_name}";
  # chmod a+x "${_tool_name}";
  unset _tool_name;


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

test:
  #!/usr/bin/env bash
  set -euxo pipefail
  bats -x tests/

init:
  #!/usr/bin/env bash
  set -euxo pipefail
  bashly init
  bashly add yaml


super-lint:
  #!/usr/bin/env bash
  set -euxo pipefail
   docker pull github/super-linter:latest
  docker run -e RUN_LOCAL=true -v {{ justfile_directory() }}:/tmp/lint github/super-linter

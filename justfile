prj_name := 'shell-lib'
lib_home := env_var_or_default('XDG_LIB_HOME', env_var('HOME') + '/.local/lib')
lib_path := env_var('BASE_PROJECT_DIR') + '/' + prj_name
dest_dir := lib_home + '/' + prj_name

default:
  @just --choose

# integrate functions from source lib
install:
  #!/usr/bin/env bash
  set -euxo pipefail
  mkdir -p {{dest_dir}}
  funs=($(ls *.sh))
  for i in ${funs[@]}; do cp {{lib_path}}/"${i}" {{dest_dir}}/; done


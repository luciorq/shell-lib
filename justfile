#!/usr/bin/env just --justfile

prj_name := 'shell-lib'
lib_home := env_var_or_default('XDG_LIB_HOME', env_var('HOME') + '/' + '.local/lib')

lib_path := env_var('_LOCAL_PROJECT') + '/' + prj_name
lib_tools_path := env_var('_LOCAL_PROJECT') + '/' + 'shell-tools'
dest_dir := lib_home + '/' + prj_name

default:
  @just --choose

create-env-build-apps:
  #!/usr/bin/env -S bash -i
  \builtin set -euxo pipefail;
  conda create -n shell-lib-env -y -c conda-forge python pyyaml pytest;

build-apps:
  #!/usr/bin/env -S bash -i
  \builtin set -euxo pipefail;
  conda run -n shell-lib-env python "{{ justfile_directory() }}/src/build_execs.py";

test-apps: build-apps
  #!/usr/bin/env -S bash -i
  \builtin set -euxo pipefail;
  conda run -n shell-lib-env python -m pytest "{{ justfile_directory() }}"/tests/test-app-*.py;

# integrate functions from source lib
install-separate:
  #!/usr/bin/env bash
  set -euxo pipefail;
  \mkdir -p "{{dest_dir}}";
  for _i in lib/*.sh; do
    \cp "{{lib_path}}/${_i}" "{{dest_dir}}/";
  done;

install-mac-launchers:
  #!/usr/bin/env -S bash -i
  set -euxo pipefail;
  for _app in $(\ls -A1 "{{lib_tools_path}}/inst/"*.command); do
    inst_path="/usr/local/bin/$(basename ${_app})";
    [[ -f ${inst_path} ]] && \sudo rm "${inst_path}";
    \sudo chmod a+x "${_app}";
    \sudo cp "${_app}" "${inst_path}";
  done

test:
  #!/usr/bin/env -S bash -i
  set -euxo pipefail;
  bats -x tests/;

is-interactive:
  #!/usr/bin/env -vS bash -i
  \builtin set -euxo pipefail;
  \builtin echo "\${-}: ${-}";
  \builtin echo "\${TERM}: ${TERM}";
  \builtin echo "\${SHELL}: ${SHELL}";
  env

super-lint:
  #!/usr/bin/env -S bash -i
  \builtin set -euxo pipefail
  docker pull github/super-linter:latest
  docker run -e RUN_LOCAL=true -v {{ justfile_directory() }}:/tmp/lint github/super-linter

user_name := env_var('USER')
# needs to be root user
install_apps_system:
  #!/usr/bin/env -S bash -i
  \builtin echo 'for _i in $(\ls -A1 /home/{{ user_name }}/projects/shell-lib/lib/*.sh); do source "${_i}"; done;\n';
  \builtin echo -ne 'source /home/{{ user_name }}/.bashrc;\n';
  \builtin echo -ne '_LOCAL_CONFIG=/home/{{ user_name }}/.config/lrq install_apps --system;\n';

test-conda-env:
  conda activate test-env;


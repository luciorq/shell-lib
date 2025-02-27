#!/usr/bin/env just --justfile

prj_name := 'shell-lib'

# org_name := 'luciorq'

# lib_home := env_var_or_default('XDG_LIB_HOME', env_var('HOME') + '/' + '.local/lib')

# lib_path := env_var('_LOCAL_PROJECT') + '/' + prj_name
# lib_tools_path := env_var('_LOCAL_PROJECT') + '/' + 'shell-tools'
# dest_dir := lib_home + '/' + prj_name

default:
  @just --choose;

@create-env-build-apps:
  #!/usr/bin/env -vS bash -i
  \builtin set -euxo pipefail;
  conda create -n shell-lib-env -y --override-channels -c conda-forge python strictyaml pytest mypy click;
  conda run -n shell-lib-env python -m pip install "{{ justfile_directory() }}/src/appbuilder";


@build-apps:
  #!/usr/bin/env -vS bash -i
  \builtin set -euxo pipefail;
  conda run -n shell-lib-env python "{{ justfile_directory() }}/src/build_execs.py";


@test-apps: build-apps
  #!/usr/bin/env -vS bash -i
  \builtin set -euxo pipefail;
  conda run -n shell-lib-env python -m pytest "{{ justfile_directory() }}"/tests/test-app-*.py;


test:
  #!/usr/bin/env -S bash -i
  set -euxo pipefail;
  bats -x tests/;


test-conda-env:
  conda activate test-env;

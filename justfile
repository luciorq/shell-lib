#!/usr/bin/env just --justfile

prj_name := 'shell-lib'

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
  conda run -n shell-lib-env python -m pip install -e "{{ justfile_directory() }}/src/appbuilder";
  conda run -n shell-lib-env python "{{ justfile_directory() }}/src/build_execs.py";


@test-apps: build-apps
  #!/usr/bin/env -vS bash -i
  \builtin set -euxo pipefail;
  conda run -n shell-lib-env python -m pytest "{{ justfile_directory() }}"/tests/test-app-*.py;

test:
  #!/usr/bin/env -S bash -i
  set -euxo pipefail;
  bats -x tests/;
  just test-apps;
#!/usr/bin/env just --justfile

prj_name := 'shell-lib'

default:
  @just --choose;

@create-env-build-apps:
  #!/usr/bin/env bash
  \builtin set -euxo pipefail;
  micromamba create -n shell-lib-env -y --override-channels -c conda-forge python pyyaml strictyaml pytest mypy click ruff;
  micromamba run -n shell-lib-env python -m pip install -e "{{ justfile_directory() }}/src/appbuilder";


@build-apps:
  #!/usr/bin/env bash
  \builtin set -euxo pipefail;
  # micromamba run -n shell-lib-env python -m appbuilder.build_execs;
  micromamba run -n shell-lib-env python -m ruff check;
  micromamba run -n shell-lib-env python -m mypy --follow-untyped-imports --install-types --non-interactive ./src/;
  micromamba run -n shell-lib-env appbuilder;


@test-apps: build-apps
  #!/usr/bin/env bash
  \builtin set -euxo pipefail;
  micromamba run -n shell-lib-env python -m pytest "{{ justfile_directory() }}"/tests/test_app_*.py -vvvv;

# test need to be run without "@" in the task call because
test:
  #!/usr/bin/env bash
  \builtin set -euxo pipefail;
  bats -x tests/;
  just test-apps;

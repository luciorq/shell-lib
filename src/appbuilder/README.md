# appbuilder

Build resilient Shell Scripts from a library of Shell functions.

Currently part of the [shell-lib](https://github.com/luciorq/shell-lib) project.

## Installation

The current implementation is designed to only run in the context of the shell-lib project.
To use it, follow the `justfile` in the root of the shell-lib project.

```bash
just create-env-build-apps
just build-apps
```

Manually debugging:

```bash
conda run -n shell-lib-env python
```

```python
from appbuilder import *

read_config("apps")

for app_name in read_config("apps").keys():
    print(app_name)


# This function has all dependencies declared in the YAML file.
build_app("dfh")

# Thus function to not have any dependencies declared in the YAML file (empty string).
build_app("which_bin")

# This function just have top level dependencies declared in the YAML file.
build_app("highlight_fun")

# Make sure all output scripts are executable
change_exec_permission("bin")
```

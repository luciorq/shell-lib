#!/usr/bin/env python3

"""
Build Resilient Bash Shell Scripts
"""

# Build Resilient Bash Shell Scripts with Python :upside_down_face:

from .utils import (
    build_app,
    change_exec_permission,
    clean_dir,
    read_config,
    stop_if_not_project_root,
)

# ==============================================================================
# main program
def main() -> int:
    stop_if_not_project_root()
    clean_dir("bin")
    # bin_list = read_config("build")

    # function_names = find_all_functions()

    # print(f"Function names: {function_names}")

    # TODO: Extracting function definition is not working.
    # + Trying workaround with subprocess("declare -f <function_name>")
    # extract_function_definition("lib/which_bin.sh", "which_bin")

    # bash_file = "lib/which_bin.sh"
    #  function_name = "which_bin"

    # For main function
    # bash_file = "lib/dfh.sh"
    print("Ready for start building!")

    for app_name in read_config("apps").keys():
        build_app(app_name)

    change_exec_permission("bin")

    print("Done!")
    # TODO: @luciorq **Create** and **Run** tests for the shell scripts.
    # + At work at `./tests/test-*.py`
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

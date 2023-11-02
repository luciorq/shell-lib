#!/usr/bin/env python3

"""
Build Resilient Bash Shell Scripts
"""

# Build Resilient Bash Shell Scripts with Python :upside_down_face:

# imports
# import os

if __name__ == "__main__":
    print("Running as a script")
    from utils import (
        stop_if_not_project_root,
        clean_dir,
        read_config,
        find_all_functions,
        build_app,
        change_exec_permission,
    )
else:
    print("Running as a module")
    from src.utils import (
        stop_if_not_project_root,
        clean_dir,
        read_config,
        find_all_functions,
        build_app,
        change_exec_permission,
    )

# local imports

# import os
# import sys
# sys.exit(0)

# ==============================================================================
# main program
stop_if_not_project_root()
clean_dir("bin")
bin_list = read_config("build")

function_names = find_all_functions()


# TODO: Extracting function definition is not working.
# + Trying workaround with subprocess("declare -f <function_name>")
# extract_function_definition("lib/which_bin.sh", "which_bin")

# bash_file = "lib/which_bin.sh"
#  function_name = "which_bin"

# For main function
# bash_file = "lib/dfh.sh"

build_app("dfh")

build_app("which_bin")

build_app("require")

build_app("download")


change_exec_permission("bin")

# TODO: **Create** and **Run** tests for the shell scripts.

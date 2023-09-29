#!/usr/bin/env python3

"""
Build Resilient Bash Shell Scripts
"""


# imports
# import os

# local imports
from utils import *
# from src.utils import *

# ==============================================================================
# main program
stop_if_not_project_root()
clean_dir('bin')
bin_list = read_config('build')

function_names = find_all_functions()


# TODO: Extracting function definition is not working.
# + Trying workaround with subprocess("declare -f <function_name>")
# extract_function_definition("lib/which_bin.sh", "which_bin")

# bash_file = "lib/which_bin.sh"
#  function_name = "which_bin"

# For main function
# bash_file = "lib/dfh.sh"

build_app("download")

change_exec_permission('bin')
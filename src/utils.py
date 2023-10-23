#!/usr/bin/env python3

"""
Utility tools for building Shell Scripts from a library of Shell functions
"""

# imports
import glob
import os
import re
import shutil
import stat
import subprocess
import sys
import yaml

# Util functions

# Equivalent to R's `stringr::str_detect()`
def str_detect(string: str, pattern: str) -> bool:
    """
    Check if a pattern is found in a string using regular expressions.

    Args:
        string (str): The input string to search within.
        pattern (str): The pattern to search for using regular expressions.

    Returns:
        bool: True if a match is found, False otherwise.

    Example:
        >>> str_detect("Hello, world!", "world")
        True
        >>> str_detect("Hello, world!", "universe")
        False
    """
    regex = re.compile(pattern)
    match = regex.search(string)
    return match is not None


# Stop execution if not in the Project root directory
def stop_if_not_project_root():
    """
    Stop execution if not in the Project root directory.
    """
    current_dir = os.getcwd()
    if not str_detect(current_dir, r"shell-lib$"):
        print("Error: Script must be executed from the project root directory.")
        sys.exit(1)


# Create and clean `bin` directory
def clean_dir(bin_dir: str):
    """
    Create and clean project `bin` directory.

    Args:
        bin_dir (str): String of the directory path.
    """
    if os.path.exists(bin_dir):
        shutil.rmtree(bin_dir)
    if not os.path.exists(bin_dir):
        os.mkdir(bin_dir)


# Define functions to be created from config YAML file
def read_config(field: str):
    """
    Read a specific field from the configuration file.

    This function reads the contents of a YAML configuration file located at 'config/build.yaml',
    and returns the value associated with the specified field.

    Args:
    - field (str): The name of the field to retrieve from the configuration file.

    Returns:
    - The value associated with the specified field in the configuration file.
    """
    config_path = os.path.join("config", "build.yaml")
    with open(config_path, "r", encoding="utf-8") as config_file:
        config_dict = yaml.safe_load(config_file)
    return config_dict[field]


# Find all function declarations in `lib` directory
def find_all_functions():
    directory = "lib"
    bash_scripts = glob.glob(os.path.join(directory, "*.sh"))
    function_names = []
    for script_file in bash_scripts:
        with open(script_file, "r", encoding="utf-8") as file:
            for line in file:
                matches = re.findall(
                    r"^(?!#).*\bfunction\b\s*\b([A-Za-z_\:][A-Za-z0-9_\:]*)\s*\(", line
                )
                function_names.extend(matches)
    function_names.sort()
    # TODO: `functions_to_remove` not implemented
    functions_to_remove = ["_usage"]
    return function_names


# Extract function definition
def extract_function_definition(function_name: str) -> str:
    """
    Extract function definition from Bash scripts.

    Args:
        function_name (str): Name of the function.

    Returns:
        str: String containing the Bash function definition.
    """
    function_declaration = subprocess.check_output(
        ["bash", "-c", "for i in lib/*.sh; do source $i; done; builtin declare -f " + function_name]
    )
    function_declaration = function_declaration.decode()
    function_declaration = re.sub(r"return", "exit", function_declaration)
    return function_declaration

# Find all function requests per file
def find_function_deps(script_name: str, function_names: str):
    """_summary_

    Args:
        script_name (str): _description_
        function_names (str): _description_

    Returns:
        _type_: _description_
    """
    script_file = os.path.join("lib", script_name + (".sh"))
    function_calls = []
    with open(script_file, mode="r", encoding="utf-8") as file:
        for line in file:
            for fun_name in function_names:
                matches = re.findall(fun_name, line)
                function_calls.extend(matches)
        # print(script_file)
    unique_defs = list(set(function_names))
    unique_defs.sort()
    function_dep_dict = {function_calls}
    return function_dep_dict


# Make sure all files in the bin directory have execute permission
def change_exec_permission(bin_dir: str):
    """
    Make sure all files in the bin directory have execute permission

    Args:
        bin_dir (str): Directory path containing the scripts
    """
    bin_files = os.listdir(bin_dir)
    for bin_file in bin_files:
        bin_file = os.path.join(bin_dir, bin_file)
        s_t = os.stat(bin_file)
        os.chmod(bin_file, s_t.st_mode | stat.S_IEXEC)

def build_app(app_name: str) -> None:
    """
    Builds Bash apps using a library of bash functions

    Args:
        app_name (str): Name of the Bash application to be built.
    """
    function_name = app_name
    dep_full_dict = read_config('apps')
    dep_list = dep_full_dict[function_name]

    main_function_def = extract_function_definition(function_name)

    for i in dep_list:
        main_function_def = main_function_def + extract_function_definition(i)

    # Add `main` function passing all parameters

    # use `#!/usr/bin/env bash` as first line
    header_str = '''#!/usr/bin/env bash

# Do NOT modify this file manually.
# Change source code at: https://github.com/luciorq/shell-lib
# Author: Lucio Rezende Queiroz
# License: MIT

builtin set -o errexit;    # abort on nonzero exitstatus
builtin set -o nounset;    # abort on unbound variable
builtin set -o pipefail;   # don\'t hide errors within pipes

[[ "${BASH_VERSINFO[0]}" -lt 4 ]] && { builtin echo >&2 "Error: Bash >=4 required"; exit 1; }

'''

    main_function = f'''
function main () {{
    { function_name } "${{@}}";
builtin exit 0;
}}

main "${{@}}";
builtin exit 0;
'''

    script_text = header_str + main_function_def + main_function
    output_path = os.path.join("bin", function_name)

    # script_text

    with open(output_path, mode = 'w', encoding = 'utf-8') as output_file:
        for line in script_text:
            output_file.write(line)
        output_file.write('\n')

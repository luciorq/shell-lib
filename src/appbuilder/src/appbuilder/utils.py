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
from typing import Any

import strictyaml

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
def stop_if_not_project_root() -> None:
    """
    Stop execution if not in the Project root directory.
    """
    current_dir = os.getcwd()
    if not str_detect(current_dir, r"shell-lib$"):
        print(
            "Error: Script must be executed from the project root directory.",
            file=sys.stderr,
        )
        sys.exit(1)


# Create and clean `bin` directory
def clean_dir(bin_dir: str) -> None:
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
def read_config(field: str) -> dict[str, Any]:
    """
    Read a specific field from the configuration file.

    This function reads the contents of a YAML configuration file located at 'config/build.yaml',
    and returns the value associated with the specified field.

    Args:
    - field (str): The name of the field to retrieve from the configuration file.

    Returns:
    - Any: The value associated with the specified field in the configuration file.
    """
    config_path = os.path.join("config", "build.yaml")
    with open(config_path, "r", encoding="utf-8") as config_file:
        yaml_text = config_file.read()
        config_dict: strictyaml.YAML = strictyaml.load(yaml_text)

    # Fail if config_dict.data is not a dict
    if not isinstance(config_dict.data, dict):
        raise ValueError(f"Expected a dictionary for field '{field}', got {type(config_dict.data)}")
    return config_dict[field].data


# Find all function declarations in `lib` directory
def find_all_functions() -> list[str]:
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
    # + functions_to_remove = ["_usage"]
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
        [
            "bash",
            "-c",
            "for i in lib/*.sh; do source $i; done; builtin declare -f "
            + function_name,
        ]
    )
    function_declaration = function_declaration.decode()
    function_declaration = re.sub(r"return 1", "exit 1", function_declaration)
    function_declaration = re.sub(r" +\n", "\n", function_declaration)
    function_declaration = f"function {function_declaration}\n"
    return function_declaration


def get_dependencies(function_code: str, all_functions: list[str]) -> list[str]:
    """
    Finds all function calls within a given function's code.

    Args:
        function_code (str): The source code of the function to analyze.
        all_functions (list[str]): A list of all possible function names to look for.

    Returns:
        list[str]: A list of function names that are called within the given code.
    """
    dependencies = []
    # Do not search for dependencies in the function declaration line itself
    try:
        body = function_code.split("{", 1)[1]
    except IndexError:
        body = ""  # No body found

    for potential_dep in all_functions:
        pattern = r"\b" + re.escape(potential_dep) + r"\b"
        if re.search(pattern, body):
            dependencies.append(potential_dep)
    return list(set(dependencies))


# Make sure all files in the bin directory have execute permission
def change_exec_permission(bin_dir: str) -> None:
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

    return None


def build_app(app_name: str) -> None:
    """
    Builds Bash apps using a library of Bash functions, resolving all dependencies recursively.

    Args:
        app_name (str): Name of the Bash application to be built.
    """
    function_name = app_name
    dep_full_dict = read_config("apps")
    direct_deps = dep_full_dict.get(function_name, [])
    if not isinstance(direct_deps, list):
        direct_deps = []

    all_known_functions = find_all_functions()

    resolved_deps: set[str] = set()

    # Queue for functions to process, starting with the app's main function and its direct dependencies
    to_process = list(set([function_name] + direct_deps))

    processed_funcs: set[str] = set()

    while to_process:
        current_func = to_process.pop(0)
        if current_func in processed_funcs:
            continue

        processed_funcs.add(current_func)

        try:
            func_definition = extract_function_definition(current_func)
            resolved_deps.add(current_func)

            # Find dependencies within the current function's body
            dependencies = get_dependencies(func_definition, all_known_functions)

            for dep in dependencies:
                if dep not in resolved_deps:
                    to_process.append(dep)

        except subprocess.CalledProcessError:
            print(
                f"Warning: Could not find definition for function '{current_func}'. Skipping.",
                file=sys.stderr,
            )

    # The main function is handled separately.
    final_deps = sorted(list(resolved_deps - {function_name}))

    # Start with the main function's definition
    main_function_def = extract_function_definition(function_name)

    # Add all resolved dependencies
    for dep in final_deps:
        main_function_def += extract_function_definition(dep)

    # Add `main` function passing all parameters

    # use `#!/usr/bin/env bash` as first line
    header_str = """#!/usr/bin/env bash

# Do NOT modify this file manually.
# Change source code at: https://github.com/luciorq/shell-lib
# Author: Lucio Rezende Queiroz
# License: MIT

\\builtin set -o errexit;    # abort on nonzero exitstatus
\\builtin set -o nounset;    # abort on unbound variable
\\builtin set -o pipefail;   # don\'t hide errors within pipes

[[ "${BASH_VERSINFO[0]}" -lt 4 ]] && { \\builtin echo >&2 "Error: Bash >=4 required"; \\builtin exit 1; }

"""

    main_function = f"""function main () {{
    { function_name } "${{@:-}}";
    \\builtin return;
}}

main "${{@:-}}";
\\builtin exit;"""

    script_text = header_str + main_function_def + main_function
    output_path = os.path.join("bin", function_name)

    # script_text

    with open(output_path, mode="w", encoding="utf-8") as output_file:
        for line in script_text:
            output_file.write(line)
        output_file.write("\n")

    return None

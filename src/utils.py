#!/usr/bin/env python3

# Module for building Shell Scripts from a library of
# + Shell functions

# imports
import re
import os
import glob
import shutil
import sys
import stat
import yaml

# Util functions

# Equivalent to R `stringr::str_detect`
def str_detect(string: str, pattern: str) -> bool:
    """
    Check if a pattern is found in a string using regular expressions.

    Parameters:
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
    import re
    regex = re.compile(pattern)
    match = regex.search(string)
    return match is not None

# Stop execution if not in the Project root directory
def stop_if_not_project_root():
    import os
    import sys
    current_dir = os.getcwd()
    if not str_detect(current_dir, r'shell-lib$'):
        print("Error: Script must be executed from the project root directory.")
        sys.exit(1)

# Create and clean `bin` directory
def clean_dir(bin_dir):
    import os
    import shutil
    if os.path.exists(bin_dir):
        shutil.rmtree(bin_dir)
    if not os.path.exists(bin_dir):
        os.mkdir(bin_dir)

# Define functions to be created from config YAML file
def read_config(field):
    import yaml
    import os
    config_path = os.path.join('config', 'build.yaml')
    with open(config_path, 'r') as config_file:
        config_dict = yaml.safe_load(config_file)
    return config_dict[field]

# Find all function declarations in `lib` directory
def find_all_functions():
    import glob
    import os
    import re
    directory = "lib"
    bash_scripts = glob.glob(os.path.join(directory, '*.sh'))
    function_names = []
    for script_file in bash_scripts:
        with open(script_file, 'r') as f:
            for line in f:
                matches = re.findall(r'^(?!#).*\bfunction\b\s*\b([A-Za-z_\:][A-Za-z0-9_\:]*)\s*\(', line)
                function_names.extend(matches)
    function_names.sort()
    functions_to_remove = [
        '_usage'
    ]
    return function_names

# Extract function definition
def extract_function_definition(bash_file, function_name):
    import re
    with open(bash_file, 'r') as file:
        bash_content = file.read()
    # Construct the regular expression pattern to match the function definition
    pattern = fr'function {function_name}.*?({{.*?}})'
    regex = re.compile(pattern, re.DOTALL)
    # Search for the function definition in the Bash content
    match = regex.search(bash_content)
    if match:
        function_definition = match.group(1)
        return function_definition.strip()
    else:
        return None


# Find all function requests per file
def find_function_deps(script_name, function_names):
    script_file = os.path.join('lib', script_name + (".sh"))
    function_calls = []
    with open(script_file, 'r') as file:
        for line in file:
            for fun_name in function_defs:
                matches = re.findall(fun_name, line)
                function_calls.extend(matches)
        # print(script_file)
    unique_defs = list(set(function_defs))
    unique_defs.sort()
    function_dep_dict = {
        function_calls 
    }
    return function_dep_dict

# Make sure all files in the bin directory have execute permission
def change_exec_permission(bin_dir):
    import os
    import stat
    bin_files = os.listdir(bin_dir)
    for bin_file in bin_files:
        bin_file = os.path.join(bin_dir, bin_file)
        st = os.stat(bin_file)
        os.chmod(bin_file, st.st_mode | stat.S_IEXEC)


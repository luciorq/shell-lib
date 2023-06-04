#!/usr/bin/env python3

# imports
import os

# local imports
from utils import *

# =====================================================================================================
# main program
stop_if_not_project_root()
clean_dir('bin')
bin_list = read_config('build')

function_names = find_all_functions()
function_dep_dict = find_function_deps(bin_list[1], function_names)

print(function_dep_dict)

# Create all files including the dependency function definition
# for script_file in bash_scripts:
#    bin_file = re.sub(r'\blib', 'bin', script_file)
#    bin_file = re.sub(r'.sh$', '', bin_file)
#    print(bin_file)
    #with open(print()

# Replace all `return` statements with `exit`
# re.sub(r'\breturn\b', 'exit')

# Add `main` function passing all parameters

# use `#!/usr/bin/env bash` as first line
header_str = '''#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don\'t hide errors within pipes

[[ "${BASH_VERSINFO[0]}" -lt 4 ]] && { builtin echo >&2 "Error: Bash >=4 required"; exit 1; }
'''

function_name = 'which_bin'

main_function = f'''
function main () {{
  { function_name } ${{@}};
  exit 0;
}}

main ${{@}};
'''

script_text = header_str + main_function
output_path = os.path.join("src", function_name)
with open(output_path, 'w') as output_file:
    for line in script_text:
        output_file.write(line)
    output_file.write('\n')

change_exec_permission('bin')

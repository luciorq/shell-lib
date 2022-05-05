#!/usr/bin/env bash

# Print useful remainders for writing
# + BASH scripts and functions
function bash_header () {
  local fn_name="${1:-function_name}";
  builtin echo -ne '#!/usr/bin/env bash\n\n';
  builtin echo -ne "# Description for ${fn_name}\n";
  builtin echo -ne "function ${fn_name} () {\n";
  builtin echo -ne '  set -o errexit;\n';
  builtin echo -ne '  set -o pipefail;\n';
  builtin echo -ne '  set -o nounset;\n';
  builtin echo -ne "  local _debug_var=\"\${DEBUG:-false}\";\n";
  builtin echo -ne "  [[ \"\${_debug_var}\" == true ]] && set -o xtrace;\n";
  builtin echo -ne "  local _usage=\"\$0 <ARGS>\";\n";
  builtin echo -ne '\n';
  builtin echo -ne '  return 0;\n';
  builtin echo -ne '}\n';
  return -0;
}

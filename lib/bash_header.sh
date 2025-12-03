#!/usr/bin/env bash
# shellcheck shell=bash

# Print useful remainders for writing
# + BASH scripts and functions
function bash_header () {
  \builtin local fn_name;
  fn_name="${1:-function_name}";
  \builtin echo -ne '#!/usr/bin/env bash\n';
  \builtin echo -ne '# shellcheck shell=bash\n\n';
  \builtin echo -ne "# Description for ${fn_name}\n";
  \builtin echo -ne '# TODO: replace \n';
  \builtin echo -ne '# + \n';
  \builtin echo -ne "function ${fn_name} () {\n";
  \builtin echo -ne '  \\builtin set -o errexit;\n';
  \builtin echo -ne '  \\builtin set -o pipefail;\n';
  \builtin echo -ne '  \\builtin set -o nounset;\n';
  \builtin echo -ne '  \\builtin local _debug_var="${DEBUG:-false}";\n';
  \builtin echo -ne '  [[ "\${_debug_var}" == true ]] && \\builtin  set -o xtrace;\n';
  \builtin echo -ne '  \\builtin local _usage;\n';
  \builtin echo -ne '  _usage="${0} <ARGS>";\n';
  \builtin echo -ne '  if [[ "${1:-}" == "-h" ]]; then\n';
  \builtin echo -ne '    \\builtin echo -ne "Usage: ${_usage}\\n";\n';
  \builtin echo -ne '    \\builtin return 0;\n';
  \builtin echo -ne '  fi\n';
  \builtin echo -ne '  \\builtin unset _usage;\n';
  \builtin echo -ne '\n';
  \builtin echo -ne '  \\builtin return 0;\n';
  \builtin echo -ne '}\n';
  \builtin return 0;
}

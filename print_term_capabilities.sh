#!/usr/bin/env bash

function __print_escape_chars () {
  echo -e '\e[1mbold\e[22m'
  echo -e '\e[2mdim\e[22m'
  echo -e '\e[3mitalic\e[23m'
  echo -e '\e[4munderline\e[24m'
  echo -e '\e[4:1mthis is also underline (new in 0.52)\e[4:0m'
  echo -e '\e[21mdouble underline (new in 0.52)\e[24m'
  echo -e '\e[4:2mthis is also double underline (new in 0.52)\e[4:0m'
  echo -e '\e[4:3mcurly underline (new in 0.52)\e[4:0m'
  echo -e '\e[5mblink (new in 0.52)\e[25m'
  echo -e '\e[7mreverse\e[27m'
  echo -e '\e[8minvisible\e[28m <- invisible (but copy-pasteable)'
  echo -e '\e[9mstrikethrough\e[29m'
  echo -e '\e[53moverline (new in 0.52)\e[55m'

  echo -e '\e[31mred\e[39m'
  echo -e '\e[91mbright red\e[39m'
  echo -e '\e[38:5:42m256-color, de jure standard (ITU-T T.416)\e[39m'
  echo -e '\e[38;5;42m256-color, de facto standard (commonly used)\e[39m'
  echo -e '\e[38:2::240:143:104mtruecolor, de jure standard (ITU-T T.416) (new in 0.52)\e[39m'
  echo -e '\e[38:2:240:143:104mtruecolor, rarely used incorrect format (might be removed at some point)\e[39m'
  echo -e '\e[38;2;240;143;104mtruecolor, de facto standard (commonly used)\e[39m'

  echo -e '\e[46mcyan background\e[49m'
  echo -e '\e[106mbright cyan background\e[49m'
  echo -e '\e[48:5:42m256-color background, de jure standard (ITU-T T.416)\e[49m'
  echo -e '\e[48;5;42m256-color background, de facto standard (commonly used)\e[49m'
  echo -e '\e[48:2::240:143:104mtruecolor background, de jure standard (ITU-T T.416) (new in 0.52)\e[49m'
  echo -e '\e[48:2:240:143:104mtruecolor background, rarely used incorrect format (might be removed at some point)\e[49m'
  echo -e '\e[48;2;240;143;104mtruecolor background, de facto standard (commonly used)\e[49m'


  echo -e '\e[21m\e[58:5:42m256-color underline (new in 0.52)\e[59m\e[24m'
  echo -e '\e[21m\e[58;5;42m256-color underline (new in 0.52)\e[59m\e[24m'
  echo -e '\e[4:3m\e[58:2::240:143:104mtruecolor underline (new in 0.52) (*)\e[59m\e[4:0m'
  echo -e '\e[4:3m\e[58:2:240:143:104mtruecolor underline (new in 0.52) (might be removed at some point) (*)\e[59m\e[4:0m'
  echo -e '\e[4:3m\e[58;2;240;143;104mtruecolor underline (new in 0.52) (*)\e[59m\e[4:0m'

  echo -e '\e]8;;https://askubuntu.com\e\\hyperlink\e]8;;\e\\ '

  echo -e "\033[5;31mBlinking text\033[0m" # Heron Hilario version
  echo -e "\e[5mBlinkingText" #
  echo -e "normal|\e[5mblink\e[0m|normal"

  return 0;
}

# This function only works correctly if the terminal is
# + using 24-bits truecolors
function __print_truecolor_scale () {
  local awk_bin;
  awk_bin="$(require 'awk')";
  builtin echo -ne "'COLORTERM' is '${COLORTERM}' in '${TERM}':\n";
  "${awk_bin}" 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
      r = 255-(colnum*255/76);
      g = (colnum*510/76);
      b = (colnum*255/76);
      if (g>255) g = 510-g;
      printf "\033[48;2;%d;%d;%dm", r,g,b;
      printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
      printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n\n";
  }'
  return 0;
}

function __print_terminal_info () {
  echo -ne "Terminal Information:\n";
  echo -ne \
    "TERM: '${TERM}';\nTERMINFO: '${TERMINFO}';\nOSTYPE: '${OSTYPE}'\n";
  echo -ne "SHELL: '${SHELL}'\n";
  if [[ ${SHELL} =~ bash ]]; then
    echo -ne "BASH_VERSION: '${BASH_VERSION} ";
    echo -ne "${BASH_VERSINFO[*]:4}'\n";
  fi
  return 0;
}

# Print terminal and shell capabilities
function print_term_capabilities () {
  __print_terminal_info;
  __print_truecolor_scale;
  __print_escape_chars;
  return 0;
}

#!/usr/bin/env bash

# open file descriptor 5 such that anything written to /dev/fd/5
# is piped through ts and then to /tmp/timestamps
exec 5> >(ts -i "%.s" >> /tmp/timestamps)

# https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
export BASH_XTRACEFD="5"

# Enable tracing
set -x

# Source my .bash_profile script, as usual
[ -n "$PS1" ] && source ~/.bashrc;

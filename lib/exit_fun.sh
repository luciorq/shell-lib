#!/usr/bin/env bash

# Exit outer most function stack with Message
function exit_fun () {
  : builtin local Error && Error=' ' && \builtin unset -v Error && "${Error:?${1:-'An error occurred. Exiting.'}}";
  \builtin return 1;
}

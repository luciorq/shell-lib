#!/usr/bin/env bash

# Exit outer most function stack with Message
function exit_fun () {
  : builtin local Error && Error=' ' && builtin unset -v Error && "${Error:?$1}";
  builtin return 1;
}

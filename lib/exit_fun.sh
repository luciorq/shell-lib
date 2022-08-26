#!/usr/bin/env bash

# Exit outer most function stack with Message
function exit_fun () {
  : local Error && Error=' ' && unset Error && "${Error:?$1}";
  return 1;
}

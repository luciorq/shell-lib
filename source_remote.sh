#!/bin/env bash

# source script from remote
function source_remote () { 
  local script_url="$1"   
  if [[ -n $(which_bin curl) ]]; then  
    source <(curl -f -s -S -L "${script_url}");
  elif [[ -n $(which_bin curl) ]]; then  
    source <(wget -q -L -nv -O - "${script_url}");
  else
    echo "download tool not available. Install 'curl' or 'wget' to continue.";
    return 1;
  fi
}

#!/usr/bin/env bash

# Check if passwordless sudo is available
# + for interactive usage, a password prompt can be
# + started first and then passwordless sudo will be available
# + for subsequent `sudo_check` calls
function sudo_check () {
  local sudo_uid su_bin
  su_bin="$(which 'sudo' || echo -ne '')"
  if [[ ${su_bin} == "" ]]; then
    echo "`sudo` program not available."
  fi
  sudo_uid=$("${su_bin}" -n id -u 2>/dev/null || id -u)
  if [[ "${sudo_uid}" == 0 ]]; then
    sudo_bool=true
  else
    sudo_bool=false
  fi
  echo "${sudo_bool}"
}


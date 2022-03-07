#!/usr/bin/env bash

# Run MacOS GUI VM
function macos_start () {
  docker start macos-vm
}


# SSH to the MacOS VM
function macos_ssh () {
  ssh -p 50922 ${USER}@localhost
}

# Opens a shared directory with running MacOS VM
function macos_shared_dir_open () {
  [[ -d ~/Documents/MacOS ]] || mkdir -p /home/${USER}/Documents/MacOS/
  sshfs -o port=50922 ${USER}@localhost:/Users/${USER} /home/${USER}/Documents/MacOS
  open /home/${USER}/Documents/MacOS
  # TODO luciorq send SSH command to VM to open Finder on the VM 
}

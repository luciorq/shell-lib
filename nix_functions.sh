#!/usr/bin/env bash

# Update nixPkgs
function nix_update () {
  local x
  nix upgrade-nix

  # to clean old installs
  # $ nix-collect-garbage -d
}

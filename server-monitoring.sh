#!/bin/env bash


# Check temperatures for nvidia
function check_temps () {
  servers_exec 'sensors; nvidia-smi -q -d temperature || echo ""'

  sensors
}



#!/usr/bin/env bash

function () {
  mamba_bin="${HOME}/.local/opt/mamba/mambaforge/condabin/mamba";

  "${mamba_bin}"

  ~/.local/opt/mamba/mambaforge/condabin/mamba create --yes --prefix ~/.local/opt/mamba/singularity singularity=3.8.7

}

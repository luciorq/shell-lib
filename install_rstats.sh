#!/bin/env bash

# Install R packages
function install_rstats_packages () {
  local config_path
  declare -a cran_packages
  declare -a bioc_packages
  declare -a gh_packages
  config_path="${HOME}"/projects/villabioinfo/bio-cluster-admin
  cran_packages=($(yq eval '.cran_packages[]' "${config_path}"/vars/r_packages.yml))
  bioc_packages=($(yq eval '.bioc_packages[]' "${config_path}"/vars/r_packages.yml))
  gh_packages=($(yq eval '.gh_packages[]' "${config_path}"/vars/r_packages.yml))

  # Install packages
  R -q -s -e \
    "if(!requireNamespace('remotes',quietly=TRUE)){install.packages('remotes')}"
  R -q -s -e \
    "if(!requireNamespace('pak',quietly=TRUE)){install.packages('pak',repos='https://r-lib.github.io/p/pak/devel/')
}"
  # R -q -s -e \
  #   "if(!requireNamespace('renv',quietly=TRUE)){install.packages('renv')}"
  
  # R -q -s -e "renv::install()"
  R -q -s -e \
    "if(!requireNamespace('BiocManager',quietly=TRUE)){pak::pkg_install('BiocManager')}"

  R -q -s -e \
    "if(!requireNamespace('BiocManager',quietly=TRUE)){BiocManager::install(version='devel')}"

  R -q -s -e \
    ""
}


function install_rstats_precompiled () {
  
  local r_version rstudio_version
  sudo apt-get update
  sudo apt-get install gdebi-core
  r_version=4.1.2
  rstudio_version=2022.06.0-daily-136 

  mkdir -p ~/temp/
  cd ~/temp/
  curl -O https://cdn.rstudio.com/r/ubuntu-2004/pkgs/r-${r_version}_1_amd64.deb
  sudo gdebi r-${r_version}_1_amd64.deb

  if [[ -e /usr/local/bin/R ]]; then rm /usr/local/bin/R; fi
  if [[ -e /usr/local/bin/Rscript ]]; then rm /usr/local/bin/Rscript; fi
  sudo ln -sf /opt/R/${r_version}/bin/R /usr/local/bin/R
  sudo ln -sf /opt/R/${r_version}/bin/Rscript /usr/local/bin/Rscript

  curl -O https://s3.amazonaws.com/rstudio-ide-build/desktop/bionic/amd64/rstudio-${rstudio_version}-amd64.deb 
  sudo gdebi rstudio-${rstudio_version}-amd64.deb

  rm ~/temp/r-*
  rm ~/temp/rstudio-*
}




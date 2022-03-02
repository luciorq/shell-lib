#/bin/env bash

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


function install_rstats_system_dependencies () {
# rriskDistributions requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev
apt-get install -y tk-table

# bdpopt requirements:
apt-get install -y jags

# RWebLogo requirements:
apt-get install -y python3

# gdata requirements:
apt-get install -y perl

# DeducerText requirements:
apt-get install -y default-jdk
R CMD javareconf

# gbp requirements:
apt-get install -y make

# prevalence requirements:
apt-get install -y jags

# dataframes2xls requirements:
apt-get install -y python3

# SBRect requirements:
apt-get install -y default-jdk
R CMD javareconf

# ezknitr requirements:
apt-get install -y pandoc

# caRpools requirements:
apt-get install -y bowtie2

# networkreporting requirements:
apt-get install -y make

# coxinterval requirements:
apt-get install -y make

# IUPS requirements:
apt-get install -y jags

# helloJavaWorld requirements:
apt-get install -y default-jdk
R CMD javareconf

# skm requirements:
apt-get install -y make

# multibiplotGUI requirements:
apt-get install -y bwidget
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev

# tutorial requirements:
apt-get install -y pandoc

# forensim requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev
apt-get install -y tk-table

# Deducer requirements:
apt-get install -y default-jdk
R CMD javareconf

# MDSGUI requirements:
apt-get install -y bwidget
apt-get install -y tk-table

# edeR requirements:
apt-get install -y default-jdk
R CMD javareconf

# PortfolioEffectHFT requirements:
apt-get install -y default-jdk
R CMD javareconf

# minqa requirements:
apt-get install -y make

# simplexreg requirements:
apt-get install -y libgsl0-dev

# elexr requirements:
apt-get install -y python3

# RFreak requirements:
apt-get install -y default-jdk
R CMD javareconf

# Rdroolsjars requirements:
apt-get install -y default-jdk
R CMD javareconf

# BiBitR requirements:
apt-get install -y default-jdk
R CMD javareconf

# gcbd requirements:
apt-get install -y nvidia-cuda-dev

# SBSA requirements:
apt-get install -y make

# sharx requirements:
apt-get install -y jags

# RKEA requirements:
apt-get install -y default-jdk
R CMD javareconf

# RNetLogo requirements:
apt-get install -y default-jdk
R CMD javareconf

# collUtils requirements:
apt-get install -y default-jdk
R CMD javareconf

# diskImageR requirements:
apt-get install -y imagej

# Plasmidprofiler requirements:
apt-get install -y pandoc

# PreKnitPostHTMLRender requirements:
apt-get install -y pandoc

# x.ent requirements:
apt-get install -y perl

# png requirements:
apt-get install -y libpng-dev

# PortfolioEffectEstim requirements:
apt-get install -y default-jdk
R CMD javareconf

# dcmle requirements:
apt-get install -y jags

# coreNLP requirements:
apt-get install -y default-jdk
R CMD javareconf

# planar requirements:
apt-get install -y make

# mallet requirements:
apt-get install -y default-jdk
R CMD javareconf

# rJython requirements:
apt-get install -y default-jdk
R CMD javareconf

# PVAClone requirements:
apt-get install -y jags

# jSonarR requirements:
apt-get install -y mongodb

# PhViD requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev
apt-get install -y tk-table

# DeducerSpatial requirements:
apt-get install -y default-jdk
R CMD javareconf

# kerasR requirements:
apt-get install -y python3

# cncaGUI requirements:
apt-get install -y bwidget
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev

# Rpoppler requirements:
apt-get install -y libglib2.0-dev
apt-get install -y libpoppler-cpp-dev

# RcmdrPlugin.RMTCJags requirements:
apt-get install -y jags

# ABC.RAP requirements:
apt-get install -y make

# orQA requirements:
apt-get install -y make

# extraTrees requirements:
apt-get install -y default-jdk
R CMD javareconf

# cycleRtools requirements:
apt-get install -y default-jdk
R CMD javareconf

# RNCBIEUtilsLibs requirements:
apt-get install -y default-jdk
R CMD javareconf

# lightsout requirements:
apt-get install -y pandoc

# poisbinom requirements:
apt-get install -y libfftw3-dev

# subspace requirements:
apt-get install -y default-jdk
R CMD javareconf

# DALY requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev
apt-get install -y tk-table

# bayescount requirements:
apt-get install -y jags

# tcltk2 requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev
apt-get install -y tk-table

# openNLPdata requirements:
apt-get install -y default-jdk
R CMD javareconf

# RSurvey requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev
apt-get install -y tk-table

# slowraker requirements:
apt-get install -y default-jdk
R CMD javareconf

# specklestar requirements:
apt-get install -y libfftw3-dev

# rGroovy requirements:
apt-get install -y default-jdk
R CMD javareconf

# mutossGUI requirements:
apt-get install -y default-jdk
R CMD javareconf

# bartMachineJARs requirements:
apt-get install -y default-jdk
R CMD javareconf

# corehunter requirements:
apt-get install -y default-jdk
R CMD javareconf

# RH2 requirements:
apt-get install -y default-jdk
R CMD javareconf

# lira requirements:
apt-get install -y jags

# Rbgs requirements:
apt-get install -y default-jdk
R CMD javareconf

# RcppMeCab requirements:
apt-get install -y make

# designmatch requirements:
apt-get install -y libglpk-dev

# TAQMNGR requirements:
apt-get install -y zlib1g-dev

# idm requirements:
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts

# rtkore requirements:
apt-get install -y make

# ChoR requirements:
apt-get install -y default-jdk
R CMD javareconf

# rhli requirements:
apt-get install -y make

# genotypeR requirements:
apt-get install -y perl

# qualpalr requirements:
apt-get install -y make

# GreedyExperimentalDesignJARs requirements:
apt-get install -y default-jdk
R CMD javareconf

# ADMMsigma requirements:
apt-get install -y make

# SCPME requirements:
apt-get install -y make

# rJPSGCS requirements:
apt-get install -y default-jdk
apt-get install -y zlib1g-dev
R CMD javareconf

# libstableR requirements:
apt-get install -y libgsl0-dev

# CommonJavaJars requirements:
apt-get install -y default-jdk
R CMD javareconf

# beanz requirements:
apt-get install -y make

# readbitmap requirements:
apt-get install -y libjpeg-dev
apt-get install -y libpng-dev

# blandr requirements:
apt-get install -y pandoc

# DeLorean requirements:
apt-get install -y make

# pysd2r requirements:
apt-get install -y python3

# RMOAjars requirements:
apt-get install -y default-jdk
R CMD javareconf

# dclone requirements:
apt-get install -y jags

# ssMousetrack requirements:
apt-get install -y make

# sequenza requirements:
apt-get install -y pandoc

# Rlda requirements:
apt-get install -y make

# RPyGeo requirements:
apt-get install -y python3

# ruta requirements:
apt-get install -y python3

# rchie requirements:
apt-get install -y libv8-dev

# jarbes requirements:
apt-get install -y jags

# Rglpk requirements:
apt-get install -y libglpk-dev

# metaMix requirements:
apt-get install -y libopenmpi-dev

# MADPop requirements:
apt-get install -y make

# dfpk requirements:
apt-get install -y make

# r.blip requirements:
apt-get install -y default-jdk
R CMD javareconf

# NestedCategBayesImpute requirements:
apt-get install -y make

# CPAT requirements:
apt-get install -y make

# aphid requirements:
apt-get install -y make

# Scalelink requirements:
apt-get install -y make

# RSAGA requirements:
apt-get install -y saga

# PBSmodelling requirements:
apt-get install -y bwidget

# StMoSim requirements:
apt-get install -y make

# rPref requirements:
apt-get install -y make

# elliptic requirements:
apt-get install -y pari-gp

# untb requirements:
apt-get install -y pari-gp

# represtools requirements:
apt-get install -y make

# igate requirements:
apt-get install -y pandoc

# bamdit requirements:
apt-get install -y jags

# otsad requirements:
apt-get install -y python3

# visit requirements:
apt-get install -y make

# LeafArea requirements:
apt-get install -y imagej
apt-get install -y default-jdk
R CMD javareconf

# MixAll requirements:
apt-get install -y make

# Rlgt requirements:
apt-get install -y make

# cloudml requirements:
apt-get install -y python3

# biplotbootGUI requirements:
apt-get install -y bwidget
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev

# OpenStreetMap requirements:
apt-get install -y default-jdk
R CMD javareconf

# rCBA requirements:
apt-get install -y default-jdk
R CMD javareconf

# jSDM requirements:
apt-get install -y libgsl0-dev

# openNLP requirements:
apt-get install -y default-jdk
R CMD javareconf

# RWekajars requirements:
apt-get install -y default-jdk
R CMD javareconf

# greta requirements:
apt-get install -y python3

# ggExtra requirements:
apt-get install -y pandoc

# RKEAjars requirements:
apt-get install -y default-jdk
R CMD javareconf

# nbconvertR requirements:
apt-get install -y pandoc
apt-get install -y python3

# BayesVarSel requirements:
apt-get install -y libgsl0-dev

# YPPE requirements:
apt-get install -y make

# optimalThreshold requirements:
apt-get install -y jags

# publipha requirements:
apt-get install -y make

# ced requirements:
apt-get install -y make

# rDEA requirements:
apt-get install -y libglpk-dev

# conStruct requirements:
apt-get install -y make

# scaffolder requirements:
apt-get install -y python3

# kza requirements:
apt-get install -y libfftw3-dev

# chebpol requirements:
apt-get install -y libfftw3-dev
apt-get install -y libgsl0-dev

# disaggregation requirements:
apt-get install -y make

# registr requirements:
apt-get install -y make

# cppRouting requirements:
apt-get install -y make

# easyNCDF requirements:
apt-get install -y libnetcdf-dev

# GRANBase requirements:
apt-get install -y git

# PopGenome requirements:
apt-get install -y zlib1g-dev

# phase1PRMD requirements:
apt-get install -y jags

# ndjson requirements:
apt-get install -y zlib1g-dev

# matchingMarkets requirements:
apt-get install -y default-jdk
R CMD javareconf

# botor requirements:
apt-get install -y python3

# REPLesentR requirements:
apt-get install -y pandoc

# SGP requirements:
apt-get install -y texlive

# qmix requirements:
apt-get install -y make

# EcoDiet requirements:
apt-get install -y jags

# LCMCR requirements:
apt-get install -y libgsl0-dev

# rblt requirements:
apt-get install -y libhdf5-dev

# RJSDMX requirements:
apt-get install -y default-jdk
R CMD javareconf

# rpostgis requirements:
apt-get install -y libpq-dev

# MethComp requirements:
apt-get install -y jags

# webshot requirements:
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts

# bfw requirements:
apt-get install -y jags
apt-get install -y default-jdk
R CMD javareconf

# gdalUtils requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin

# JMbayes requirements:
apt-get install -y jags

# rapidjsonr requirements:
apt-get install -y make

# pandocfilters requirements:
apt-get install -y pandoc

# NobBS requirements:
apt-get install -y jags

# Orcs requirements:
apt-get install -y make

# pdSpecEst requirements:
apt-get install -y make

# rsparkling requirements:
apt-get install -y default-jdk
R CMD javareconf

# dti requirements:
apt-get install -y libgsl0-dev

# spsurv requirements:
apt-get install -y make

# tsmp requirements:
apt-get install -y make

# oceanmap requirements:
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts

# meltt requirements:
apt-get install -y python3

# irace requirements:
apt-get install -y make

# rscala requirements:
apt-get install -y default-jdk
R CMD javareconf

# moveVis requirements:
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts

# gMCP requirements:
apt-get install -y default-jdk
R CMD javareconf

# conflr requirements:
apt-get install -y pandoc

# reproj requirements:
apt-get install -y libproj-dev

# patternplot requirements:
apt-get install -y make

# osmose requirements:
apt-get install -y default-jdk
R CMD javareconf

# concaveman requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# blastula requirements:
apt-get install -y pandoc

# glmulti requirements:
apt-get install -y default-jdk
R CMD javareconf

# DCPO requirements:
apt-get install -y make

# bioimagetools requirements:
apt-get install -y libfftw3-dev
apt-get install -y libcurl4-openssl-dev
apt-get install -y libtiff-dev
apt-get install -y libssl-dev

# CausalQueries requirements:
apt-get install -y make

# bacistool requirements:
apt-get install -y jags

# BCHM requirements:
apt-get install -y jags

# texreg requirements:
apt-get install -y texlive
apt-get install -y pandoc

# pdfminer requirements:
apt-get install -y python3

# bellreg requirements:
apt-get install -y make

# bigMap requirements:
apt-get install -y make

# YPBP requirements:
apt-get install -y make

# uavRmp requirements:
apt-get install -y make

# HydeNet requirements:
apt-get install -y jags

# rstantools requirements:
apt-get install -y pandoc

# DNAtools requirements:
apt-get install -y make

# glmmfields requirements:
apt-get install -y make

# roll requirements:
apt-get install -y make

# breathteststan requirements:
apt-get install -y make

# MUACz requirements:
apt-get install -y make

# rstanarm requirements:
apt-get install -y make
apt-get install -y pandoc-citeproc
apt-get install -y pandoc

# camtrapR requirements:
apt-get install -y libimage-exiftool-perl

# image.CannyEdges requirements:
apt-get install -y libfftw3-dev
apt-get install -y libpng-dev

# lcra requirements:
apt-get install -y jags

# modeLLtest requirements:
apt-get install -y make

# bsem requirements:
apt-get install -y make

# microclass requirements:
apt-get install -y make

# MaOEA requirements:
apt-get install -y python3

# IOHexperimenter requirements:
apt-get install -y make

# bsam requirements:
apt-get install -y jags

# uchardet requirements:
apt-get install -y make

# RODBC requirements:
apt-get install -y unixodbc-dev

# XML requirements:
apt-get install -y libxml2-dev

# hadron requirements:
apt-get install -y libgsl0-dev

# MBNMAdose requirements:
apt-get install -y jags

# pcnetmeta requirements:
apt-get install -y jags

# arrangements requirements:
apt-get install -y libgmp3-dev

# FLSSS requirements:
apt-get install -y make

# tables requirements:
apt-get install -y pandoc

# rmdcev requirements:
apt-get install -y make

# devEMF requirements:
apt-get install -y libfreetype6-dev
apt-get install -y libxft-dev
apt-get install -y zlib1g-dev

# rjdmarkdown requirements:
apt-get install -y default-jdk
R CMD javareconf

# HDPenReg requirements:
apt-get install -y make

# SAR requirements:
apt-get install -y make

# rTorch requirements:
apt-get install -y pandoc-citeproc
apt-get install -y pandoc
apt-get install -y python3

# cbq requirements:
apt-get install -y make

# cleanNLP requirements:
apt-get install -y python3

# MrSGUIDE requirements:
apt-get install -y make

# trialr requirements:
apt-get install -y make

# MixSIAR requirements:
apt-get install -y jags

# BeastJar requirements:
apt-get install -y default-jdk
R CMD javareconf

# kantorovich requirements:
apt-get install -y libgmp3-dev

# milr requirements:
apt-get install -y make

# JavaGD requirements:
apt-get install -y make
apt-get install -y default-jdk
R CMD javareconf

# colorizer requirements:
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts

# sudachir requirements:
apt-get install -y python3

# xlsx requirements:
apt-get install -y default-jdk
R CMD javareconf

# varitas requirements:
apt-get install -y perl

# bayesGAM requirements:
apt-get install -y make

# GWnnegPCA requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# potential requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# qCBA requirements:
apt-get install -y default-jdk
R CMD javareconf

# mwa requirements:
apt-get install -y default-jdk
R CMD javareconf

# rstanemax requirements:
apt-get install -y make

# rmdfiltr requirements:
apt-get install -y pandoc

# mRpostman requirements:
apt-get install -y libcurl4-openssl-dev
apt-get install -y libssl-dev

# ggdemetra requirements:
apt-get install -y default-jdk
R CMD javareconf

# streamMOA requirements:
apt-get install -y default-jdk
R CMD javareconf

# wordnet requirements:
apt-get install -y default-jdk
R CMD javareconf

# gitcreds requirements:
apt-get install -y git

# dynBiplotGUI requirements:
apt-get install -y make

# GreedyExperimentalDesign requirements:
apt-get install -y default-jdk
R CMD javareconf

# loo requirements:
apt-get install -y pandoc-citeproc
apt-get install -y pandoc

# bpcs requirements:
apt-get install -y make

# motifr requirements:
apt-get install -y python3

# RAppArmor requirements:
apt-get install -y libapparmor-dev

# GetoptLong requirements:
apt-get install -y perl

# DataExplorer requirements:
apt-get install -y pandoc

# bartMachine requirements:
apt-get install -y default-jdk
R CMD javareconf

# StanHeaders requirements:
apt-get install -y pandoc

# FFD requirements:
apt-get install -y bwidget

# frequency requirements:
apt-get install -y pandoc

# TreeBUGS requirements:
apt-get install -y jags

# adimpro requirements:
apt-get install -y dcraw
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts

# RcppBigIntAlgos requirements:
apt-get install -y libgmp3-dev

# prettydoc requirements:
apt-get install -y pandoc

# staplr requirements:
apt-get install -y default-jdk
R CMD javareconf

# GeneralizedUmatrix requirements:
apt-get install -y pandoc

# NACHO requirements:
apt-get install -y pandoc-citeproc
apt-get install -y pandoc

# ECOSolveR requirements:
apt-get install -y make

# extRatum requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# feamiR requirements:
apt-get install -y python3

# idem requirements:
apt-get install -y make

# topicmodels requirements:
apt-get install -y libgsl0-dev

# rTRNG requirements:
apt-get install -y make

# EvidenceSynthesis requirements:
apt-get install -y default-jdk
R CMD javareconf

# worcs requirements:
apt-get install -y pandoc

# morse requirements:
apt-get install -y jags

# Crossover requirements:
apt-get install -y default-jdk
R CMD javareconf

# survHE requirements:
apt-get install -y make

# mfbvar requirements:
apt-get install -y make

# SymbolicDeterminants requirements:
apt-get install -y libgmp3-dev

# ech requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# shinyloadtest requirements:
apt-get install -y pandoc

# metagear requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev

# rkeops requirements:
apt-get install -y cmake
apt-get install -y nvidia-cuda-dev

# CBSr requirements:
apt-get install -y default-jdk
R CMD javareconf

# tiler requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y python3

# MIRES requirements:
apt-get install -y make

# mlr requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libglu1-mesa-dev
apt-get install -y libgmp3-dev
apt-get install -y libgsl0-dev
apt-get install -y jags
apt-get install -y libmpfr-dev
apt-get install -y libopenmpi-dev
apt-get install -y libproj-dev

# Boom requirements:
apt-get install -y make

# multibridge requirements:
apt-get install -y make
apt-get install -y libmpfr-dev

# rsubgroup requirements:
apt-get install -y default-jdk
R CMD javareconf

# spatsoc requirements:
apt-get install -y libgeos-dev

# rmsb requirements:
apt-get install -y make

# PRIMME requirements:
apt-get install -y make

# scModels requirements:
apt-get install -y libgmp3-dev
apt-get install -y libmpfr-dev

# RPushbullet requirements:
[ $(which google-chrome) ] || apt-get install -y gnupg curl
[ $(which google-chrome) ] || curl -fsSL -o /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
[ $(which google-chrome) ] || DEBIAN_FRONTEND='noninteractive' apt-get install -y /tmp/google-chrome.deb
rm -f /tmp/google-chrome.deb

# fftwtools requirements:
apt-get install -y libfftw3-dev

# forImage requirements:
apt-get install -y python3

# phonfieldwork requirements:
apt-get install -y pandoc

# ondisc requirements:
apt-get install -y make

# CTD requirements:
apt-get install -y libgmp3-dev

# rchallenge requirements:
apt-get install -y pandoc

# gastempt requirements:
apt-get install -y make

# govdown requirements:
apt-get install -y pandoc

# LMMELSM requirements:
apt-get install -y make

# pkgnews requirements:
apt-get install -y pandoc

# altmeta requirements:
apt-get install -y jags

# metaBMA requirements:
apt-get install -y make

# DataPackageR requirements:
apt-get install -y pandoc

# baseflow requirements:
apt-get install -y make
apt-get install -y rustc
apt-get install -y cargo

# exifr requirements:
apt-get install -y perl

# r2pmml requirements:
apt-get install -y default-jdk
R CMD javareconf

# plumberDeploy requirements:
apt-get install -y libssh2-1-dev

# drf requirements:
apt-get install -y make

# prophet requirements:
apt-get install -y make

# HierDpart requirements:
apt-get install -y make

# WriteXLS requirements:
apt-get install -y perl

# ProcData requirements:
apt-get install -y python3

# brinton requirements:
apt-get install -y pandoc

# sasfunclust requirements:
apt-get install -y make

# modeltime.h2o requirements:
apt-get install -y default-jdk
R CMD javareconf

# bmggum requirements:
apt-get install -y make

# rapport requirements:
apt-get install -y pandoc

# SIBER requirements:
apt-get install -y jags

# AWR requirements:
apt-get install -y default-jdk
R CMD javareconf

# mixture requirements:
apt-get install -y libgsl0-dev

# quantdr requirements:
apt-get install -y make

# breathtestcore requirements:
apt-get install -y pandoc

# BANOVA requirements:
apt-get install -y jags

# foieGras requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y pandoc
apt-get install -y libproj-dev

# gifski requirements:
apt-get install -y rustc
apt-get install -y cargo

# pivmet requirements:
apt-get install -y pandoc-citeproc
apt-get install -y pandoc

# juicr requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev

# TCIU requirements:
apt-get install -y make

# ssh requirements:
apt-get install -y libssh2-1-dev

# hBayesDM requirements:
apt-get install -y make

# rzmq requirements:
apt-get install -y libzmq3-dev

# xslt requirements:
apt-get install -y libxslt-dev

# ropenblas requirements:
apt-get install -y make

# RGF requirements:
apt-get install -y python3

# sass requirements:
apt-get install -y make

# rviewgraph requirements:
apt-get install -y default-jdk
R CMD javareconf

# detrendr requirements:
apt-get install -y make

# RKEEL requirements:
apt-get install -y default-jdk
R CMD javareconf

# cubature requirements:
apt-get install -y make

# huxtable requirements:
apt-get install -y texlive

# h2o4gpu requirements:
apt-get install -y python3

# markovchain requirements:
apt-get install -y make

# dialr requirements:
apt-get install -y default-jdk
R CMD javareconf

# cit requirements:
apt-get install -y libgsl0-dev

# bayesZIB requirements:
apt-get install -y make

# unmarked requirements:
apt-get install -y make

# RcppAlgos requirements:
apt-get install -y libgmp3-dev

# autocart requirements:
apt-get install -y make

# GMKMcharlie requirements:
apt-get install -y make

# rapidraker requirements:
apt-get install -y default-jdk
R CMD javareconf

# ip2location requirements:
apt-get install -y python3

# flan requirements:
apt-get install -y libgsl0-dev

# BivRec requirements:
apt-get install -y make

# mapview requirements:
apt-get install -y make

# entropart requirements:
apt-get install -y pandoc

# mbbefd requirements:
apt-get install -y make

# seqinr requirements:
apt-get install -y zlib1g-dev

# nucim requirements:
apt-get install -y libfftw3-dev
apt-get install -y libcurl4-openssl-dev
apt-get install -y libtiff-dev
apt-get install -y libssl-dev

# BINtools requirements:
apt-get install -y make

# crandep requirements:
apt-get install -y pandoc

# pander requirements:
apt-get install -y pandoc

# diversitree requirements:
apt-get install -y libfftw3-dev
apt-get install -y libgsl0-dev

# bayesplot requirements:
apt-get install -y pandoc-citeproc
apt-get install -y pandoc

# rextendr requirements:
apt-get install -y rustc
apt-get install -y cargo

# bayesforecast requirements:
apt-get install -y make

# jagsUI requirements:
apt-get install -y jags

# GGally requirements:
apt-get install -y libssl-dev

# ggquickeda requirements:
apt-get install -y pandoc

# curl requirements:
apt-get install -y libcurl4-openssl-dev
apt-get install -y libssl-dev

# bdpar requirements:
apt-get install -y python3

# RcppRedis requirements:
apt-get install -y libhiredis-dev

# sen2r requirements:
apt-get install -y libcairo2-dev
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libxml2-dev
apt-get install -y libnetcdf-dev
apt-get install -y libssl-dev
apt-get install -y libproj-dev
apt-get install -y libv8-dev

# tkRplotR requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev

# textmineR requirements:
apt-get install -y make

# ijtiff requirements:
apt-get install -y libjpeg-dev
apt-get install -y libtiff-dev
apt-get install -y zlib1g-dev

# ROpenCVLite requirements:
apt-get install -y cmake

# hpa requirements:
apt-get install -y make

# jackalope requirements:
apt-get install -y make

# FCPS requirements:
apt-get install -y pandoc

# sdmApp requirements:
apt-get install -y default-jdk
R CMD javareconf

# smam requirements:
apt-get install -y make
apt-get install -y libgsl0-dev

# textrecipes requirements:
apt-get install -y make

# DA requirements:
apt-get install -y make

# magickGUI requirements:
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts

# rater requirements:
apt-get install -y make

# grf requirements:
apt-get install -y make

# seewave requirements:
apt-get install -y libsndfile1-dev

# iMRMC requirements:
apt-get install -y default-jdk
R CMD javareconf

# SDMtune requirements:
apt-get install -y default-jdk
R CMD javareconf

# bayesbr requirements:
apt-get install -y make

# AovBay requirements:
apt-get install -y make

# jpeg requirements:
apt-get install -y libjpeg-dev

# OpenCL requirements:
apt-get install -y ocl-icd-opencl-dev

# PoissonBinomial requirements:
apt-get install -y libfftw3-dev

# ergm requirements:
apt-get install -y libopenmpi-dev

# blockcluster requirements:
apt-get install -y make

# findInGit requirements:
apt-get install -y git

# cld3 requirements:
apt-get install -y libprotobuf-dev
apt-get install -y protobuf-compiler

# protolite requirements:
apt-get install -y libprotobuf-dev
apt-get install -y protobuf-compiler

# fRLR requirements:
apt-get install -y libgsl0-dev

# haven requirements:
apt-get install -y make
apt-get install -y zlib1g-dev

# InSilicoVA requirements:
apt-get install -y default-jdk
R CMD javareconf

# R2jags requirements:
apt-get install -y jags

# reprex requirements:
apt-get install -y pandoc

# excerptr requirements:
apt-get install -y python3

# bbsBayes requirements:
apt-get install -y jags

# concatipede requirements:
apt-get install -y make

# reportfactory requirements:
apt-get install -y pandoc

# sysfonts requirements:
apt-get install -y libfreetype6-dev
apt-get install -y libpng-dev
apt-get install -y zlib1g-dev

# rmumps requirements:
apt-get install -y make

# caviarpd requirements:
apt-get install -y rustc
apt-get install -y cargo

# geouy requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# websocket requirements:
apt-get install -y make
apt-get install -y libssl-dev

# sentometrics requirements:
apt-get install -y make

# magick requirements:
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts

# ip2proxy requirements:
apt-get install -y python3

# densEstBayes requirements:
apt-get install -y make

# RNetCDF requirements:
apt-get install -y libnetcdf-dev
apt-get install -y libudunits2-dev

# bridger requirements:
apt-get install -y texlive

# ubiquity requirements:
apt-get install -y perl

# arulesNBMiner requirements:
apt-get install -y default-jdk
R CMD javareconf

# CNVRG requirements:
apt-get install -y make

# bookdown requirements:
apt-get install -y pandoc

# link2GI requirements:
apt-get install -y make

# fuzzywuzzyR requirements:
apt-get install -y python3

# nmslibR requirements:
apt-get install -y python3

# GeoMongo requirements:
apt-get install -y mongodb
apt-get install -y python3

# strawr requirements:
apt-get install -y libcurl4-openssl-dev
apt-get install -y libssl-dev

# MBNMAtime requirements:
apt-get install -y jags

# rmarkdown requirements:
apt-get install -y pandoc

# rmBayes requirements:
apt-get install -y make

# hsstan requirements:
apt-get install -y make

# OncoBayes2 requirements:
apt-get install -y make
apt-get install -y pandoc-citeproc
apt-get install -y pandoc

# RODBC requirements:
apt-get install -y unixodbc-dev

# rmcfs requirements:
apt-get install -y default-jdk
R CMD javareconf

# XML requirements:
apt-get install -y libxml2-dev

# SimInf requirements:
apt-get install -y libgsl0-dev

# nlrx requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y default-jdk
apt-get install -y libxml2-dev
apt-get install -y libssl-dev
apt-get install -y pandoc
apt-get install -y libproj-dev
apt-get install -y libudunits2-dev
R CMD javareconf

# glmmTMB requirements:
apt-get install -y make

# specmine requirements:
apt-get install -y python3

# DesignCTPB requirements:
apt-get install -y nvidia-cuda-dev
apt-get install -y libssl-dev

# clinUtils requirements:
apt-get install -y pandoc

# orderly requirements:
apt-get install -y git

# IncDTW requirements:
apt-get install -y make

# lgpr requirements:
apt-get install -y make

# pcFactorStan requirements:
apt-get install -y make

# thurstonianIRT requirements:
apt-get install -y make

# trackdem requirements:
apt-get install -y libimage-exiftool-perl
apt-get install -y python3

# catSurv requirements:
apt-get install -y make

# data.table requirements:
apt-get install -y zlib1g-dev

# Thermimage requirements:
apt-get install -y libimage-exiftool-perl
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts
apt-get install -y perl

# RMOA requirements:
apt-get install -y default-jdk
R CMD javareconf

# bayes4psy requirements:
apt-get install -y make

# inTextSummaryTable requirements:
apt-get install -y pandoc

# patientProfilesVis requirements:
apt-get install -y texlive

# bayesdfa requirements:
apt-get install -y make

# s2 requirements:
apt-get install -y libssl-dev

# bmlm requirements:
apt-get install -y make

# CoNI requirements:
apt-get install -y python3

# XLConnect requirements:
apt-get install -y default-jdk
R CMD javareconf

# mrbayes requirements:
apt-get install -y make

# clinDataReview requirements:
apt-get install -y pandoc

# TriDimRegression requirements:
apt-get install -y make

# redist requirements:
apt-get install -y libgmp3-dev
apt-get install -y libxml2-dev
apt-get install -y libopenmpi-dev
apt-get install -y python3

# BayesSenMC requirements:
apt-get install -y make

# eggCounts requirements:
apt-get install -y make

# Rssa requirements:
apt-get install -y libfftw3-dev

# landsepi requirements:
apt-get install -y libgsl0-dev

# seqR requirements:
apt-get install -y make

# animation requirements:
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts
apt-get install -y texlive

# lwgeom requirements:
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# Rlibeemd requirements:
apt-get install -y libgsl0-dev

# RcppGSL requirements:
apt-get install -y libgsl0-dev

# vapour requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libproj-dev

# coga requirements:
apt-get install -y libgsl0-dev

# VBLPCM requirements:
apt-get install -y libgsl0-dev

# StanMoMo requirements:
apt-get install -y make

# nimble requirements:
apt-get install -y make

# PandemicLP requirements:
apt-get install -y make

# GWmodel requirements:
apt-get install -y make

# switchboard requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev

# dataMaid requirements:
apt-get install -y git
apt-get install -y pandoc

# PReMiuM requirements:
apt-get install -y make

# dismo requirements:
apt-get install -y default-jdk
R CMD javareconf

# survSNP requirements:
apt-get install -y libgsl0-dev

# rjags requirements:
apt-get install -y jags

# saotd requirements:
apt-get install -y libgsl0-dev
apt-get install -y libmpfr-dev

# textshaping requirements:
apt-get install -y libfreetype6-dev
apt-get install -y libfribidi-dev
apt-get install -y libharfbuzz-dev

# landmap requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# dodgr requirements:
apt-get install -y make

# pharmr requirements:
apt-get install -y python3

# MFPCA requirements:
apt-get install -y libfftw3-dev

# rminizinc requirements:
apt-get install -y pandoc

# rcdk requirements:
apt-get install -y default-jdk
R CMD javareconf

# slasso requirements:
apt-get install -y make

# XBRL requirements:
apt-get install -y libxml2-dev

# econetwork requirements:
apt-get install -y libgsl0-dev

# digitalDLSorteR requirements:
apt-get install -y python3

# SuperGauss requirements:
apt-get install -y libfftw3-dev

# BayesXsrc requirements:
apt-get install -y make

# rpf requirements:
apt-get install -y make

# epidemia requirements:
apt-get install -y make

# CoordinateCleaner requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin

# QF requirements:
apt-get install -y libgsl0-dev

# BrailleR requirements:
apt-get install -y python3

# sodium requirements:
apt-get install -y libsodium-dev

# BTSPAS requirements:
apt-get install -y jags

# apcf requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev

# pRecipe requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libproj-dev

# rmatio requirements:
apt-get install -y zlib1g-dev

# Rmpfr requirements:
apt-get install -y libgmp3-dev
apt-get install -y libmpfr-dev

# mwaved requirements:
apt-get install -y libfftw3-dev

# glpkAPI requirements:
apt-get install -y libglpk-dev

# bigGP requirements:
apt-get install -y libopenmpi-dev

# tsapp requirements:
apt-get install -y libfftw3-dev

# runjags requirements:
apt-get install -y jags

# webp requirements:
apt-get install -y libwebp-dev

# fftw requirements:
apt-get install -y libfftw3-dev

# gmp requirements:
apt-get install -y libgmp3-dev

# saeHB requirements:
apt-get install -y jags

# gsl requirements:
apt-get install -y libgsl0-dev

# PKI requirements:
apt-get install -y libssl-dev

# PTXQC requirements:
apt-get install -y pandoc

# datasailr requirements:
apt-get install -y make

# jqr requirements:
apt-get install -y libjq-dev

# BGVAR requirements:
apt-get install -y make

# pbdMPI requirements:
apt-get install -y libopenmpi-dev

# scs requirements:
apt-get install -y make

# popbayes requirements:
apt-get install -y jags

# mongolite requirements:
apt-get install -y libssl-dev
apt-get install -y libsasl2-dev

# rasciidoc requirements:
apt-get install -y python3

# asbio requirements:
apt-get install -y bwidget

# hoopR requirements:
apt-get install -y pandoc-citeproc
apt-get install -y pandoc

# dataReporter requirements:
apt-get install -y git
apt-get install -y pandoc

# BayesPostEst requirements:
apt-get install -y jags

# RJDemetra requirements:
apt-get install -y default-jdk
R CMD javareconf

# PMCMRplus requirements:
apt-get install -y libgmp3-dev
apt-get install -y libmpfr-dev

# autoharp requirements:
apt-get install -y pandoc

# MapeBay requirements:
apt-get install -y make

# hdf5r requirements:
apt-get install -y libhdf5-dev

# RSiena requirements:
apt-get install -y make

# pathfindR requirements:
apt-get install -y default-jdk
R CMD javareconf

# officedown requirements:
apt-get install -y pandoc

# RWeka requirements:
apt-get install -y default-jdk
R CMD javareconf

# unix requirements:
apt-get install -y libapparmor-dev

# cartogramR requirements:
apt-get install -y libfftw3-dev

# Statsomat requirements:
apt-get install -y texlive
apt-get install -y pandoc
apt-get install -y python3

# dynr requirements:
apt-get install -y make

# rcdd requirements:
apt-get install -y libgmp3-dev

# exiftoolr requirements:
apt-get install -y perl

# imager requirements:
apt-get install -y libfftw3-dev
apt-get install -y libtiff-dev

# adass requirements:
apt-get install -y make

# rgl requirements:
apt-get install -y libfreetype6-dev
apt-get install -y libglu1-mesa-dev
apt-get install -y libpng-dev
apt-get install -y libgl1-mesa-dev
apt-get install -y pandoc
apt-get install -y zlib1g-dev

# MIMSunit requirements:
apt-get install -y libxml2-dev
apt-get install -y libssl-dev

# xgboost requirements:
apt-get install -y make

# ctrdata requirements:
apt-get install -y perl

# string2path requirements:
apt-get install -y rustc
apt-get install -y cargo

# git2r requirements:
apt-get install -y libgit2-dev
apt-get install -y libssh2-1-dev
apt-get install -y libssl-dev
apt-get install -y zlib1g-dev

# ltable requirements:
apt-get install -y libgsl0-dev

# symengine requirements:
apt-get install -y cmake
apt-get install -y libgmp3-dev
apt-get install -y make
apt-get install -y libmpfr-dev

# matrixprofiler requirements:
apt-get install -y make

# Rmixmod requirements:
apt-get install -y make

# RBesT requirements:
apt-get install -y make
apt-get install -y pandoc-citeproc
apt-get install -y pandoc

# Rserve requirements:
apt-get install -y make

# bootUR requirements:
apt-get install -y make

# argparse requirements:
apt-get install -y python3

# bssm requirements:
apt-get install -y pandoc

# GWpcor requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# fsdaR requirements:
apt-get install -y default-jdk
R CMD javareconf

# neuronorm requirements:
apt-get install -y cmake

# JointAI requirements:
apt-get install -y jags

# keyring requirements:
apt-get install -y libsecret-1-dev

# credentials requirements:
apt-get install -y git

# stringi requirements:
apt-get install -y libicu-dev

# odbc requirements:
apt-get install -y make
apt-get install -y unixodbc-dev

# xml2 requirements:
apt-get install -y libxml2-dev

# rflsgen requirements:
apt-get install -y default-jdk
R CMD javareconf

# remotes requirements:
apt-get install -y git

# EpiSignalDetection requirements:
apt-get install -y pandoc

# ubms requirements:
apt-get install -y make

# GeoFIS requirements:
apt-get install -y libgmp3-dev
apt-get install -y make
apt-get install -y libmpfr-dev

# opencpu requirements:
apt-get install -y libapparmor-dev
apt-get install -y pandoc

# stringfish requirements:
apt-get install -y make

# bcTSNE requirements:
apt-get install -y make

# vitae requirements:
apt-get install -y pandoc

# GPBayes requirements:
apt-get install -y libgsl0-dev

# rkafka requirements:
apt-get install -y default-jdk
R CMD javareconf

# KSgeneral requirements:
apt-get install -y libfftw3-dev

# Rsagacmd requirements:
apt-get install -y saga

# exactextractr requirements:
apt-get install -y libgeos-dev

# leidenAlg requirements:
apt-get install -y make

# rkafkajars requirements:
apt-get install -y default-jdk
R CMD javareconf

# gdalcubes requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libnetcdf-dev

# mailR requirements:
apt-get install -y default-jdk
R CMD javareconf

# RCzechia requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# jagstargets requirements:
apt-get install -y jags

# ragg requirements:
apt-get install -y libfreetype6-dev
apt-get install -y libjpeg-dev
apt-get install -y libpng-dev
apt-get install -y libtiff-dev

# salso requirements:
apt-get install -y rustc
apt-get install -y cargo

# paws.common requirements:
apt-get install -y pandoc

# sdcTable requirements:
apt-get install -y libglpk-dev

# anticlust requirements:
apt-get install -y libglpk-dev
apt-get install -y pandoc

# fs requirements:
apt-get install -y make

# SimJoint requirements:
apt-get install -y make

# rJava requirements:
apt-get install -y make
apt-get install -y default-jdk
R CMD javareconf

# rTLS requirements:
apt-get install -y make

# spcosa requirements:
apt-get install -y default-jdk
R CMD javareconf

# gpg requirements:
apt-get install -y libgpgme11-dev
apt-get install -y haveged

# gslnls requirements:
apt-get install -y libgsl0-dev

# RMySQL requirements:
apt-get install -y libmysqlclient-dev

# tmbstan requirements:
apt-get install -y make

# RDieHarder requirements:
apt-get install -y libgsl0-dev

# conleyreg requirements:
apt-get install -y make

# tidycwl requirements:
apt-get install -y pandoc

# rticles requirements:
apt-get install -y make

# precommit requirements:
apt-get install -y git

# bmgarch requirements:
apt-get install -y make

# pema requirements:
apt-get install -y make

# ncdf4 requirements:
apt-get install -y libnetcdf-dev

# rgeos requirements:
apt-get install -y libgeos-dev

# ggiraph requirements:
apt-get install -y libpng-dev

# rgdal requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libproj-dev

# pagedown requirements:
apt-get install -y pandoc

# knitr requirements:
apt-get install -y pandoc

# RProtoBuf requirements:
apt-get install -y libprotobuf-dev
apt-get install -y protobuf-compiler

# rtmpt requirements:
apt-get install -y libgsl0-dev

# isotracer requirements:
apt-get install -y make

# RPostgres requirements:
apt-get install -y libpq-dev

# mwcsr requirements:
apt-get install -y default-jdk
R CMD javareconf

# biblio requirements:
apt-get install -y pandoc

# RMariaDB requirements:
apt-get install -y libmysqlclient-dev

# openssl requirements:
apt-get install -y libssl-dev

# rstan requirements:
apt-get install -y make
apt-get install -y pandoc

# workflowr requirements:
apt-get install -y pandoc

# gfilogisreg requirements:
apt-get install -y libgmp3-dev

# Cairo requirements:
apt-get install -y libcairo2-dev

# eaf requirements:
apt-get install -y make
apt-get install -y libgsl0-dev

# IRkernel requirements:
apt-get install -y python3

# simplermarkdown requirements:
apt-get install -y pandoc

# surveil requirements:
apt-get install -y make

# gert requirements:
apt-get install -y libgit2-dev

# cogmapr requirements:
apt-get install -y libcurl4-openssl-dev
apt-get install -y libssl-dev

# h3jsr requirements:
apt-get install -y libv8-dev

# igraph requirements:
apt-get install -y libglpk-dev
apt-get install -y libgmp3-dev
apt-get install -y libxml2-dev

# baggr requirements:
apt-get install -y make

# bspm requirements:
apt-get install -y python3

# pcaL1 requirements:
apt-get install -y coinor-libclp-dev

# ftExtra requirements:
apt-get install -y pandoc

# httpuv requirements:
apt-get install -y make
apt-get install -y zlib1g-dev

# RcppParallel requirements:
apt-get install -y make

# MFSIS requirements:
apt-get install -y python3

# udunits2 requirements:
apt-get install -y libudunits2-dev

# ymd requirements:
apt-get install -y rustc
apt-get install -y cargo

# BayesCACE requirements:
apt-get install -y jags

# bfp requirements:
apt-get install -y make

# psrwe requirements:
apt-get install -y make

# soilhypfit requirements:
apt-get install -y libgmp3-dev
apt-get install -y libmpfr-dev

# SqlRender requirements:
apt-get install -y default-jdk
R CMD javareconf

# abn requirements:
apt-get install -y libgsl0-dev

# tesseract requirements:
apt-get install -y libleptonica-dev
apt-get install -y libtesseract-dev
apt-get install -y tesseract-ocr-eng

# idiogramFISH requirements:
apt-get install -y pandoc

# JGR requirements:
apt-get install -y default-jdk
R CMD javareconf

# mappoly requirements:
apt-get install -y make

# redux requirements:
apt-get install -y libhiredis-dev

# coveffectsplot requirements:
apt-get install -y pandoc

# rbioacc requirements:
apt-get install -y make

# RoBMA requirements:
apt-get install -y jags

# gwsem requirements:
apt-get install -y make

# bistablehistory requirements:
apt-get install -y make

# PoissonMultinomial requirements:
apt-get install -y libfftw3-dev

# inlpubs requirements:
apt-get install -y pandoc

# openCR requirements:
apt-get install -y make

# rcbayes requirements:
apt-get install -y make

# N2R requirements:
apt-get install -y make

# FlexReg requirements:
apt-get install -y make

# pkgdown requirements:
apt-get install -y pandoc

# causact requirements:
apt-get install -y python3

# PoolTestR requirements:
apt-get install -y make

# lamW requirements:
apt-get install -y make

# strm requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# redland requirements:
apt-get install -y librdf0-dev

# memoiR requirements:
apt-get install -y pandoc

# BayesGWQS requirements:
apt-get install -y jags

# HiClimR requirements:
apt-get install -y libnetcdf-dev

# RQuantLib requirements:
apt-get install -y libquantlib0-dev

# rofanova requirements:
apt-get install -y make

# EPP requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libssl-dev
apt-get install -y libproj-dev

# dbmss requirements:
apt-get install -y make
apt-get install -y pandoc

# inlmisc requirements:
apt-get install -y pandoc

# MetaStan requirements:
apt-get install -y make

# tiledb requirements:
apt-get install -y cmake
apt-get install -y git

# glmmPen requirements:
apt-get install -y make

# nloptr requirements:
apt-get install -y cmake

# reticulate requirements:
apt-get install -y python3

# h2o requirements:
apt-get install -y default-jdk
R CMD javareconf

# clustermq requirements:
apt-get install -y libzmq3-dev

# blavaan requirements:
apt-get install -y make

# OpenImageR requirements:
apt-get install -y libfftw3-dev
apt-get install -y libjpeg-dev
apt-get install -y libpng-dev

# ClusterR requirements:
apt-get install -y libfftw3-dev

# neptune requirements:
apt-get install -y python3

# forsearch requirements:
apt-get install -y libgmp3-dev

# terra requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# archive requirements:
apt-get install -y libarchive-dev

# RAQSAPI requirements:
apt-get install -y pandoc

# proj4 requirements:
apt-get install -y libproj-dev

# walker requirements:
apt-get install -y make

# tidysq requirements:
apt-get install -y make

# tiff requirements:
apt-get install -y libjpeg-dev
apt-get install -y libtiff-dev

# TDA requirements:
apt-get install -y libgmp3-dev

# RcppCWB requirements:
apt-get install -y libglib2.0-dev
apt-get install -y make

# OpenMx requirements:
apt-get install -y make

# baker requirements:
apt-get install -y jags

# stplanr requirements:
apt-get install -y make

# httpgd requirements:
apt-get install -y libcairo2-dev
apt-get install -y libfontconfig1-dev
apt-get install -y libfreetype6-dev
apt-get install -y libpng-dev

# switchr requirements:
apt-get install -y git

# fcirt requirements:
apt-get install -y make

# factset.protobuf.stach.v2 requirements:
apt-get install -y libprotobuf-dev
apt-get install -y protobuf-compiler

# multinma requirements:
apt-get install -y make

# PlanetNICFI requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin

# pbdSLAP requirements:
apt-get install -y libopenmpi-dev

# svglite requirements:
apt-get install -y libpng-dev

# V8 requirements:
apt-get install -y libv8-dev

# pbdZMQ requirements:
apt-get install -y libzmq3-dev

# emayili requirements:
apt-get install -y pandoc

# sf requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev

# dialrjars requirements:
apt-get install -y default-jdk
R CMD javareconf

# units requirements:
apt-get install -y libudunits2-dev

# rego requirements:
apt-get install -y make

# libsoc requirements:
apt-get install -y libxml2-dev

# ridge requirements:
apt-get install -y libgsl0-dev

# IceSat2R requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin

# seqminer requirements:
apt-get install -y make
apt-get install -y zlib1g-dev

# rsvg requirements:
apt-get install -y librsvg2-dev

# asteRisk requirements:
apt-get install -y make

# minidown requirements:
apt-get install -y pandoc

# RCurl requirements:
apt-get install -y make
apt-get install -y libcurl4-openssl-dev

# bioacoustics requirements:
apt-get install -y libfftw3-dev
apt-get install -y make

# rubias requirements:
apt-get install -y make

# showtext requirements:
apt-get install -y libfreetype6-dev
apt-get install -y libpng-dev
apt-get install -y zlib1g-dev

# zoid requirements:
apt-get install -y make

# CytOpT requirements:
apt-get install -y python3

# geostan requirements:
apt-get install -y make

# arrow requirements:
apt-get install -y libcurl4-openssl-dev
apt-get install -y libssl-dev

# tipsae requirements:
apt-get install -y make

# nanonext requirements:
apt-get install -y cmake

# rMIDAS requirements:
apt-get install -y python3

# geno2proteo requirements:
apt-get install -y perl

# secr requirements:
apt-get install -y make

# dtwclust requirements:
apt-get install -y make

# monoreg requirements:
apt-get install -y libgsl0-dev

# r5r requirements:
apt-get install -y default-jdk
R CMD javareconf

# text requirements:
apt-get install -y python3

# DIZutils requirements:
apt-get install -y libpq-dev

# R2SWF requirements:
apt-get install -y libfreetype6-dev
apt-get install -y libpng-dev
apt-get install -y zlib1g-dev

# systemfonts requirements:
apt-get install -y libfontconfig1-dev
apt-get install -y libfreetype6-dev

# gittargets requirements:
apt-get install -y git

# DatabaseConnector requirements:
apt-get install -y default-jdk
R CMD javareconf

# caracas requirements:
apt-get install -y python3

# factset.protobuf.stachextensions requirements:
apt-get install -y libprotobuf-dev
apt-get install -y protobuf-compiler

# altair requirements:
apt-get install -y python3

# bhmbasket requirements:
apt-get install -y jags

# gdtools requirements:
apt-get install -y libcairo2-dev
apt-get install -y libfontconfig1-dev
apt-get install -y libfreetype6-dev

# ctsem requirements:
apt-get install -y make

# blogdown requirements:
apt-get install -y pandoc

# ravetools requirements:
apt-get install -y libfftw3-dev

# pdftools requirements:
apt-get install -y libpoppler-cpp-dev

}

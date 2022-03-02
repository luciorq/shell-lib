#!/bin/env bash

function install_gromacs () {

  local source_url install_path

  sudo apt install cmake

  wget https://ftp.gromacs.org/gromacs/gromacs-2021.4.tar.gz

  tar xfz gromacs-2021.4.tar.gz

  cd gromacs-2021.4

  mkdir build
  cd build

  # Build
  CMAKE_INCLUDE_PATH=/usr/local/cuda cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_INSTALL_PREFIX=/opt/apps/bioinfo/gromacs -DGMX_MPI=on -DMPI_C_COMPILER=mpicc -DGMX_GPU=CUDA -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda

  # Compile
  make -j 10
  make check
  sudo make install

  # Link executables
  sudo ln -s /opt/apps/bioinfo/gromacs/bin/GMXRC /usr/local/bin/GMXRC
  sudo ln -s /opt/apps/bioinfo/gromacs/bin/gmx_mpi /usr/local/bin/gmx
  sudo ln -s /opt/apps/bioinfo/gromacs/bin/gmx_mpi /usr/local/bin/gmx_mpi

  # Link Additional scripts
  sudo ln -s /opt/apps/bioinfo/gromacs/bin/demux.pl /usr/local/bin/demux.pl
  sudo ln -s /opt/apps/bioinfo/gromacs/bin/xplor2gmx.pl /usr/local/bin/xplor2gmx.pl
  
  # Source configuration environment variables
  # + should be added by user... Why?
  source /usr/local/bin/GMXRC
}


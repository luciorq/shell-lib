#!/usr/bin/env bash

# Install R (r-devel) from source
# + Linking to openMP and FL
function __install_rstats_source_hb () {

  # Deps: as of https://cran.r-project.org/doc/manuals/r-devel/R-admin.html#Essential-and-useful-other-programs-under-a-Unix_002dalike
  # + gcc,
  # + gfortran
  # + readline - headers at:
  # + libiconv
  # + zlib
  # + libbz2 - 'brew install bzip2'
  # + liblzma, actually included in 'brew install xz'
  # + pcre2
  # + libcurl
  # Execute to expose the libcurl variables:
  # + texinfo
  # + texi2html
  # + gettext
  # + cairo
  # + pango
  # + libjpeg: brew install jpeg
  # + libpnb
  # + libtiff

  # === Non essential support ===
  # + tcltk - brew install tcl-tk
  # + java - openjdk
  # For linux, additionally, apt names:
  # + xorg-dev

  local brew_bin;
  local brew_pkgs brew_pkg;
  brew_bin="$(which_bin 'brew')"
  declare -a brew_pkgs=(
    bzip2
    xz
    curl
    grep
    gnu-sed
    gnu-tar
    gettext
    texinfo
    texi2html
    libomp
    libiconv
    cairo
    pango
    jpeg
    libpng
    libtiff
    tcl-tk
    lapack
    make
    bash
    webp
    openjpeg
    openjdk
    llvm
    open-mpi
    binutils
    pcre2
    readline
    coreutils
    gfortran
    gcc
  )
  for brew_pkg in ${brew_pkgs[@]}; do
    "${brew_bin}" install "${brew_pkg}";
  done

  # Casks
  brew install --cask mactex
  brew install --cask xquartz

  # ========================================================================
  # using custom tap from https://github.com/sethrfore/homebrew-r-srf
  # + Formula: sethrfore/r-srf/r
  brew tap sethrfore/homebrew-r-srf
  brew install --build-from-source \
    sethrfore/r-srf/r \
    --with-cairo-x11 \
    --with-tcl-tk-x11 \
    --with-libtiff \
    --with-openjdk \
    --with-texinfo \
    --with-openblas \
    --with-icu4c

  # After install
  sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
  sudo R CMD javareconf
}

# Install R from CRAN source
function __install_rstats_source_cran () {
# ========================================================================
  # Using devel source from cran
  # For R-devel
  downlaod https://stat.ethz.ch/R/daily/R-devel.tar.gz r-tmp/
  unpack r-tmp/R-devel.tar.gz r-tmp/
  cd r-tmp/R-devel

  local pkg path_str ld_str pkgconfig_str;
  local lib_str include_str;
  local brew_prefix;
  brew_prefix="$(brew --prefix)";
  _bp="${brew_prefix}/opt";

  bca_prefix="${HOME}/.local/opt/bca"

  path_str="${PATH}";
  ld_str="/opt/homebrew/lib";
  lib_str="-L/opt/X11/lib -L/opt/homebrew/lib";
  include_str="-I/opt/X11/include -I/opt/homebrew/include";
  pkgconfig_str="/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig";

  for pkg in ${brew_pkgs[@]}; do
    echo $pkg;
    path_str="${_bp}/${pkg}/bin:${path_str}";
    lib_str="-L${_bp}/${pkg}/lib ${lib_str}";
    ld_str="${_bp}/${pkg}/lib:${ld_str}";
    include_str="-I${_bp}/${pkg}/include ${include_str}";
    pkgconfig_str="${_bp}/${pkg}/lib/pkgconfig:${pkgconfig_str}";
  done

  # https://colinfay.me/r-installation-administration/appendix-b-configuration-on-a-unix-alike.html

  # TODO luciorq define ld_flags and cpp_flags based on the lib_str and include_str, respectively
  # Custom try with homebrew
  # + --enable-jit is broken on arm64
  dash_ver='-11'

  export PATH="${path_str}"
  export LD_LIBRARY_PATH="${ld_str}"
  export JAVA_HOME="${brew_prefix}/opt/openjdk"
  export R_JAVA_HOME="${brew_prefix}/opt/openjdk"
  export R_BATCHSAVE='--no-save'
  export R_PAPERSIZE='a4'
  export R_BROWSER='/usr/bin/open'
  export R_SHELL="${brew_prefix}/bin/bash"
  export CC=clang
  export FC=gfortran
  export CXX=clang++
  export LIBS="${lib_str}"
  export MAKE=cmake
  export TAR=gtar
  export SED=gsed
  # export LDFLAGS="-mtune=native -g -O2 -Wall -pedantic -Wconversion ${lib_str}"
  export LDFLAGS="${lib_str}"
  # export CFLAGS="-mtune=native -g -O2 -Wall -pedantic -Wconversion ${include_str}"
  export CFLAGS="${include_str}"
  # export FFLAGS="-mtune=native -g -O2 -Wall -pedantic -Wconversion ${include_str}"
  export FFLAGS="${include_str}"
  # export CXXFLAGS="-mtune=native -g -O2 -Wall -pedantic -Wconversion ${include_str}"
  export CPPFLAGS="${include_str}"
  export CXXFLAGS="${include_str}"
  export PKG_CONFIG="${brew_prefix}/bin/pkg-config"
  export PKG_CONFIG_PATH="${pkgconfig_str}"
  ./configure \
    --config-cache \
    --prefix="${bca_prefix}/R/devel" \
    --enable-memory-profiling \
    --with-blas \
    --with-lapack \
    --with-x=no \
    --x-includes="/opt/X11/include" \
    --x-libraries="/opt/X11/lib" \
    --with-readline=yes \
    --with-pcre2 \
    --with-tcltk \
    --without-aqua \
    --with-libpng \
    --with-jpeglib \
    --with-libtiff \
    --with-cairo \
    --with-recommended-packages

  # To remove macos specific variations
  # + use: --without-aqua
  #   --enable-R-shlib \
  # + not working: --enable-utf8 and --enable-jit
  n_threads="$(nproc)";
  make_threads="$(( ${n_threads} + 1 ))";
  gmake -j "${make_threads}" -O;
  gmake install;
  # After Install ===============================================
  sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
  sudo R CMD javareconf


}

# ========================
# Install Homebrew R
# + and tries to fix broken package installations on arm64 MacOS
function __install_rstats_hb () {
  brew install \
    gh \
    openssl \
    automake \
    gmake;
  local config_sub_path;

  # FS broken
  fs_path="${HOME}/temp/clones/fs";
  gh repo clone r-lib/fs "${fs_path}";
  config_sub_path='${HOME}/temp/clones/fs/src/libuv*/config.sub';
  config_sub_path=$(realpath $(eval echo "$config_sub_path"));
  builtin echo 'echo arm-apple-darwin' > "${config_sub_path}";
  r_bin="$(which_bin R)";
  dep_r_pkg='remotes';
  "${r_bin}" -q -s -e "if(isFALSE(base::requireNamespace('${dep_r_pkg}',quietly=TRUE))){install.packages('${dep_r_pkg}')}";
  "${r_bin}" -q -s -e "remotes::install_local(path='${fs_path}')";
  rm -rf "${fs_path}";

  # HTTPUV broken
  pkg_repo='rstudio/httpuv';
  pkg_name="$(basename ${pkg_repo})";
  clone_path="${HOME}/temp/clones/${pkg_name}";
  gh repo clone ${pkg_repo} "${clone_path}";
  fd_bin="$(require 'fd')";
  config_sub_path=$("${fd_bin}" --no-ignore --hidden --follow "config.sub" "${clone_path}/src")
  builtin echo 'echo arm-apple-darwin' > "${config_sub_path}";
  "${r_bin}" -q -s -e "remotes::install_local(path='${clone_path}')";
  rm -rf "${clone_path}";

  # stringi broken
  brew reinstall icu4
  "${r_bin}" -q -s -e \
    "withr::with_makevars(c(CC='gcc-11',CXX='g++-11',CXXFLAGS='-fopenmp -L/opt/homebrew/opt/icu4c/lib'),install.packages('stringi',type='source'))"

  # gaborcsardi/prompt broken
  pkg_repo='gaborcsardi/prompt'
  pkg_name="$(basename ${pkg_repo})";
  clone_path="${HOME}/temp/clones/${pkg_name}";
  gh repo clone ${pkg_repo} "${clone_path}";
}

# Install R packages
function __install_rstats_packages () {
  local config_path;
  config_path="$_LOCAL_CONFIG/vars/rstats_packages.yaml";
  declare -a cran_packages=$(parse_yaml "${config_path}" default cran_packages);
  declare -a bioc_packages=$(parse_yaml "${config_path}" default bioc_packages);
  declare -a gh_packages=$(parse_yaml "${config_path}" default gh_packages);
  # brew dependencies
  declare -a brew_deps=(
    curl
    openssl
    libgit2 # gert
    llvm
    automake
    nlopt
    boost
    proj
    openjdk
  )

  sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
  sudo R CMD javareconf

  r_bin="$(require R)";
  # Install Package CRAN
  for cran_pkg in ${cran_packages[@]}; do
    install_rstats_pkg "${cran_pkg}";
  done

  install_rstats_pkg 'remotes';
  #  from GitHub
  for gh_pkg in ${gh_packages[@]}; do
    # gh_pkg_name="$(basename ${gh_pkg})";
    install_rstats_pkg "${gh_pkg}" 'gh';
  done
  # from BioConductor
  install_rstats_pkg 'BiocManager';
  # For devel Bioconductor
  R -q -s -e \
    "if(requireNamespace('BiocManager',quietly=TRUE)){BiocManager::install(version='devel')}";
  R -q -s -e \
    "if(requireNamespace('BiocManager',quietly=TRUE)){BiocManager::install()}";
  for bioc_pkg in ${bioc_packages[@]}; do
    install_rstats_pkg "${bioc_pkg}" 'bioc';
  done
}

function install_rstats_pkg () {
  local pkg_name;
  local pkg_type
  local r_bin;
  cran_pkg="$1";
  pkg_type="${2:-cran}";
  r_bin="$(require R)";
  case ${pkg_type} in
    cran)      install_str='install.packages'           ;;
    gh)        install_str='remotes::install_github'    ;;
    local)     install_str='remotes::install_local'     ;;
    bioc*)     install_str='BiocManager::install'       ;;
  esac
  "${r_bin}" -q -s -e \
    "if(isFALSE(base::requireNamespace('${cran_pkg}',quietly=TRUE))){${install_str}('${cran_pkg}')}";
}


function __install_rstats_precompiled () {

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

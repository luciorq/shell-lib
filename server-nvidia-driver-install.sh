#!/usr/bin/env bash

# Install Nvidia Driver Headless for Ubuntu Server
# + tested on Ubuntu Server 20.04.3 LTS
# + 2021-12-13 22:40

# Second test
# + tested on Ubuntu Server 20.04.4 LTS
# + 2022-03-23 15:50



# Remove 32 bits packages
function __remove_32bits_pkgs () {
  local lib_arr;
  local lib_var;
  declare -a lib_arr=( $(dpkg --get-selections | grep ":i386" | awk '{print $1}') );
  for lib_var in ${lib_arr[@]}; do
    sudo apt remove --purge --yes ${lib_var};
  done
  sudo dpkg --remove-architecture i386;
}

# Install nvidia headless driver
function install-nvidia-driver () {
  local nvidia_version;
  local cuda_version;
  nvidia_version='510';
  cuda_version='11.6.1';


  # TODO luciorq Remove previous versions;

  # check If device can be found
  lspci | grep -i nvidia;
  # Install Kernel Developer headers
  sudo apt-get install --yes linux-headers-$(uname -r);

  # for OFED support


  sudo apt update -y -q

  sudo apt install -y -q \
    zlib1g \
    nvidia-headless-${nvidia_version} \
    nvidia-utils-${nvidia_version}

}

# Monitor GPU
function check-nvidia-driver () {
  nvidia-smi
  nvcc --version
}

# Install CUDA
function install_cuda_lang () {
  # Check this website for updated version
  # + https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=runfile_local
  # wget https://developer.download.nvidia.com/compute/cuda/11.5.1/local_installers/cuda_11.5.1_495.29.05_linux.run
  cuda_version='11.6.1';
  os_string='ubuntu2004';
  version_dash='11-6';
  cuda_string="${os_string}-${version_dash}-local_11.6.1-510.47.03-1_amd64";

  # TODO luciorq Remove previous versions 
  # sudo rm /etc/apt/sources.list.d/cuda-ubuntu2004-11-5-local.list
  local old_pkgs_arr old_pkg;
  declare -a old_pkgs_arr=( $(sudo apt list --installed | grep cuda | grep -v "${cuda_version}" | cut -d'/' -f1) );
  for old_pkg in ${old_pkg_arr[@]}; do
    sudo apt remove --purge --yes ${old_pkg};
  done

  # TODO luciorq Check if it ubuntu 20.04
  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
  sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600

  wget "https://developer.download.nvidia.com/compute/cuda/${cuda_version}/local_installers/cuda-repo-${cuda_string}.deb";
  sudo dpkg -i cuda-repo-*.deb;
  sudo apt-key add "/var/cuda-repo-ubuntu2004-${version_dash}-local/7fa2af80.pub";

  # sudo apt-key add /var/cuda-repo-ubuntu2004-11-5-local/7fa2af80.pub
  sudo apt update --yes;
  sudo apt install --yes cuda;


  # Install cuDNN
  wget https://developer.nvidia.com/compute/cudnn/secure/8.3.1/local_installers/11.5/cudnn-linux-x86_64-8.3.1.22_cuda11.5-archive.tar.xz
  # If download denied access: https://developer.nvidia.com/rdp/cudnn-download locally
  # + and move it through SCP
  # scp cudnn-linux-x86_64-8.3.1.22_cuda11.5-archive.tar.xz bioinfo@chaves:temp/cuda/
  tar -xvf cudnn-linux-x86_64-8.3.1.22_cuda11.5-archive.tar.xz

  sudo cp cudnn-*-archive/include/cudnn*.h /usr/local/cuda/include
  sudo cp -P cudnn-*-archive/lib/libcudnn* /usr/local/cuda/lib64
  sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*




}


# Test CUDA installation
function test_cuda () {
  wget https://github.com/NVIDIA/cuda-samples/archive/v11.5.tar.gz
  tar xvf v11.5.tar.gz
  cd cuda-samples-11.5
  # gtx 1050 ti has compute capability 6.1 (Pascal architecture)
  # + Add SMS='61' to make based on the achitecture
  make SMS="61"

  ./bin/x86_64/linux/release/immaTensorCoreGemm

}



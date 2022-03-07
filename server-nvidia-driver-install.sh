#!/usr/bin/env bash

# Install Nvidia Driver Headless for Ubuntu Server
# + tested on Ubuntu Server 20.04.3 LTS
# + 2021-12-13 22:40
function install-nvidia-driver () {
  local nvidia_version
  nvidia_version='495'
  cuda_version='11.5.1'
  sudo apt update -y -q
  sudo apt install -y -q \
    zlib1g vidia-headless-${nvidia_version} nvidia-utils-${nvidia_version}

}

# Monitor GPU
function check-nvidia-driver () {
  nvidia-smi
  nvcc --version
}

# Install CUDA
function install-cuda-lang () {
  # Check this website for updated version
  # + https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=runfile_local
  # wget https://developer.download.nvidia.com/compute/cuda/11.5.1/local_installers/cuda_11.5.1_495.29.05_linux.run


  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin  
  sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600

  wget https://developer.download.nvidia.com/compute/cuda/11.5.1/local_installers/cuda-repo-ubuntu2004-11-5-local_11.5.1-495.29.05-1_amd64.deb

  sudo dpkg -i cuda-repo-ubuntu2004-11-5-local_11.5.1-495.29.05-1_amd64.deb
  sudo apt-key add /var/cuda-repo-ubuntu2004-11-5-local/7fa2af80.pub
  sudo apt update
  sudo apt -y install cuda


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



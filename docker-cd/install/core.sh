#!/bin/bash

set -e
set -u
set -o pipefail

# Install libraries for building c++ core on Almalinux
dnf install -y wget xz python3 python3-pip ncurses-devel cargo gcc-toolset-11 # ncurses-devel for libtinfo
ln -s /usr/bin/python3 /usr/bin/python

# Install multibuild utils
git clone https://github.com/matthew-brett/multibuild.git && cd multibuild &&
	git checkout 9e2349833e994cb829b77cc08f1aacc6ab6d2458

# Install CMake
dnf makecache --refresh
dnf -y install cmake
dnf -y --enablerepo=powertools install ninja-build

# Install LLVM
dnf makecache --refresh
dnf install -y llvm llvm-devel

# Install upgraded patchelf due to the bug in patchelf 0.10
# see details at https://stackoverflow.com/questions/61007071/auditwheel-repair-not-working-as-expected
cd /tmp/ && git clone https://github.com/NixOS/patchelf.git
cd /tmp/patchelf && ./bootstrap.sh && ./configure && make -j4 && make check && make install
rm -r /tmp/patchelf

# Install Vulkan SDK
export vulkan_version="1.3.236.0"
mkdir -p ~/vulkan
cd /tmp
wget https://sdk.lunarg.com/sdk/download/${vulkan_version}/linux/vulkansdk-linux-x86_64-${vulkan_version}.tar.gz
tar xf vulkansdk-linux-x86_64-${vulkan_version}.tar.gz -C ~/vulkan
rm vulkansdk-linux-x86_64-${vulkan_version}.tar.gz
export VULKAN_SDK=~/vulkan/${vulkan_version}/x86_64
cp -ar $VULKAN_SDK/include/* /usr/include/
cp -p $VULKAN_SDK/lib/libSPIRV* /usr/lib64/
cp -P $VULKAN_SDK/lib/libvulkan* /usr/lib64/
cp -P $VULKAN_SDK/lib/libVkLayer_* /usr/lib64/
ln -s /usr/lib64/libSPIRV-Tools-shared.so /usr/lib64/libSPIRV-Tools.so

# Git safety configuration
git config --global --add safe.directory "*"

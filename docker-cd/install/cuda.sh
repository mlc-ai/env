#!/bin/bash
set -e
set -o pipefail

CUDA_PKG_NAME=$1 # e.g. "cuda-11-7"
CUDA_TXT_NAME=$2 # e.g. "cuda11.7"

dnf install epel-release -y
dnf update -y
rpm -q epel-release
yum config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
dnf install kernel-devel -y
dnf install $CUDA_PKG_NAME -y

NCCL_VERSION=$(dnf --showduplicates list libnccl | grep "$CUDA_TXT_NAME" | tail -1 | awk '{print $2}')
dnf install libnccl-$NCCL_VERSION libnccl-devel-$NCCL_VERSION libnccl-static-$NCCL_VERSION -y

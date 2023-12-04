#!/bin/bash
set -e
set -o pipefail

ROCM_VER=$1 # e.g. "5.6"

dnf install -y epel-release

tee --append /etc/yum.repos.d/rocm.repo <<EOF
[ROCm-$ROCM_VER]
name=ROCm$ROCM_VER
baseurl=https://repo.radeon.com/rocm/rhel8/$ROCM_VER/main
enabled=1
priority=50
gpgcheck=1
gpgkey=https://repo.radeon.com/rocm/rocm.gpg.key
EOF

dnf install -y rocm-hip-sdk

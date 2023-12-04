#!/bin/bash
set -exo pipefail

curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj --strip-components=1 -C /tmp/ bin/micromamba
mkdir /root/bin/
mv /tmp/micromamba $MAMBA_EXE

echo "alias conda=\"micromamba\"" >>~/.bashrc

$MAMBA_EXE shell init -s bash -p $MAMBA_ROOT_PREFIX
$MAMBA_EXE env create --yes -f /conda/ci-lint.yml

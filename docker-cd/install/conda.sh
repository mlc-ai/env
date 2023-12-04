#!/bin/bash
set -e
set -o pipefail

cd /tmp && wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
/tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda
rm /tmp/Miniconda3-latest-Linux-x86_64.sh
chmod -R a+w /opt/conda/
conda update --yes -n base -c defaults conda
conda install -n base conda-libmamba-solver
conda config --set solver libmamba
conda upgrade --all
conda install conda-build conda-verify

conda env create -y -n py37 -f /install/conda/cd-py37.yml
conda env create -y -n py38 -f /install/conda/cd-py38.yml
conda env create -y -n py39 -f /install/conda/cd-py39.yml
conda env create -y -n py310 -f /install/conda/cd-py310.yml
conda env create -y -n py311 -f /install/conda/cd-py311.yml
conda env create -y -n py312 -f /install/conda/cd-py312.yml
conda clean --yes --all

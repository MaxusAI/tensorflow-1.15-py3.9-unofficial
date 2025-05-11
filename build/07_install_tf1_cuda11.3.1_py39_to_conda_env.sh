#!/bin/bash
# This script sets up a Conda environment for TensorFlow 1.15.5 based on the project's Dockerfile and setup files.
set -eu # Exit on error, undefined variable

# --- Configuration ---
PYTHON_VERSION="3.9"; # As specified in the user query and Dockerfile context

CUDA_VERSION_MAJOR="11";
CUDA_VERSION_MINOR="3";
CUDA_VERSION_PATCH="1";
# From Dockerfile 'conda install cuda-version=11.3'
CUDA_TOOLKIT_VERSION="${CUDA_VERSION_MAJOR}.${CUDA_VERSION_MINOR}.${CUDA_VERSION_PATCH}";

CONDA_HOME="/opt/conda";
CONDA_ENV_NAME="python${PYTHON_VERSION}_tf1_cuda${CUDA_TOOLKIT_VERSION}_env";

CONDA_BIN="${CONDA_HOME}/bin/conda";

# Define Python and Pip paths for the created environment
PYTHON_ENV="${CONDA_HOME}/envs/${CONDA_ENV_NAME}"
PYTHON="${PYTHON_ENV}/bin/python"
PIP="${PYTHON_ENV}/bin/pip"

echo "Python executable for this environment: ${PYTHON}"
echo "Pip executable for this environment: ${PIP}"

sudo -H ${PYTHON} -m pip install \
    ../wheels/${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/py${PYTHON_VERSION}/tensorflow-1.15.5*.whl

sudo -H ${PIP} check

sudo -H ${PYTHON} \
    -c "import tensorflow as tf; print(tf.test.is_gpu_available())"
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



# Determine Conda installation path
# Try common locations or allow user to set CONDA_HOME
if [ -n "${CONDA_HOME}" ] && [ -d "${CONDA_HOME}" ]; then
    echo "Using CONDA_HOME: ${CONDA_HOME}"
elif [ -d "${HOME}/miniconda3" ]; then
    CONDA_HOME="${HOME}/miniconda3"
    echo "Found Miniconda3 at: ${CONDA_HOME}"
elif [ -d "${HOME}/anaconda3" ]; then
    CONDA_HOME="${HOME}/anaconda3"
    echo "Found Anaconda3 at: ${CONDA_HOME}"
else
    echo "Error: CONDA_HOME is not set and common Conda installations (Miniconda3/Anaconda3 in HOME) were not found."
    echo "Please set CONDA_HOME to your Conda installation directory or install Conda first."
    exit 1
fi

CONDA_BIN="${CONDA_HOME}/bin/conda";

if ! [ -x "${CONDA_BIN}" ]; then
    echo "Error: Conda executable not found at ${CONDA_BIN} or is not executable."
    echo "Please ensure CONDA_HOME is set correctly, Conda is installed, and ${CONDA_BIN} is executable."
    exit 1
fi

echo "--- Creating Conda Environment: ${CONDA_ENV_NAME} with Python ${PYTHON_VERSION} ---"
if "${CONDA_BIN}" env list | grep -q "^${CONDA_ENV_NAME}\\s"; then
    echo "Conda environment '${CONDA_ENV_NAME}' already exists."
    echo "To recreate it, please remove it first: conda env remove -n ${CONDA_ENV_NAME}"
else
    echo "DEBUG (before create): CONDA_BIN='${CONDA_BIN}'"
    echo "DEBUG (before create): CONDA_ENV_NAME='${CONDA_ENV_NAME}'"
    echo "DEBUG (before create): PYTHON_VERSION='${PYTHON_VERSION}'"
    "${CONDA_BIN}" create -y -q \
        -n "${CONDA_ENV_NAME}" \
        python="${PYTHON_VERSION}"
    echo "Conda environment '${CONDA_ENV_NAME}' created successfully."
fi

# Define Python and Pip paths for the created environment
PYTHON_ENV="${CONDA_HOME}/envs/${CONDA_ENV_NAME}"
PYTHON="${PYTHON_ENV}/bin/python"
PIP="${PYTHON_ENV}/bin/pip"

echo "Python executable for this environment: ${PYTHON}"
echo "Pip executable for this environment: ${PIP}"

# Ensure the pip executable exists before trying to use it
if ! [ -x "${PIP}" ]; then
    echo "Error: Pip executable not found at ${PIP} after environment creation."
    echo "Please check the conda create step."
    exit 1
fi
# No 'conda activate' or 'source conda.sh' needed from this point

echo "--- Installing Core Conda Packages (CUDA VERSION, HDF5, MPI, etc.) ---"
# Based on Dockerfile 'conda install' section
"${CONDA_BIN}" install -y \
    --name "${CONDA_ENV_NAME}" \
    --channel nvidia \
    --channel rapidsai \
    --channel conda-forge \
    cuda-version="${CUDA_VERSION_MAJOR}.${CUDA_VERSION_MINOR}" \
    libboost \
    hdf5 \
    "h5py<3" \
    "openmpi<5" \
    ucx \
    mpi4py

echo "--- Installing Core Conda Packages (CUDATOOLKIT, CuDNN, CUDART, NCCL, etc.) ---"
# Conda Env with Cuda 11.3
"${CONDA_BIN}" install -y \
    --name "${CONDA_ENV_NAME}" \
    --channel nvidia \
    --channel rapidsai \
    --channel conda-forge \
    cuda-version="${CUDA_VERSION_MAJOR}.${CUDA_VERSION_MINOR}" \
    cudatoolkit \
    "cudnn<9" \
    cuda-cudart \
    nccl

echo "--- Upgrading PIP and Installing Essential Python Build Tools ---"
# Based on Dockerfile 'pip install --upgrade pip wheel setuptools "Cython<3"'
"${PIP}" install --upgrade \
    pip \
    wheel \
    setuptools \
    "Cython<3"

echo "--- Installing PyCurl with OpenSSL ---"
# Based on Dockerfile PyCurl installation
PYCURL_SSL_LIBRARY=openssl \
    "${PIP}" install --upgrade \
        --ignore-installed --compile \
        pycurl

echo "--- Installing Python Dependencies for TensorFlow ---"
# Combined and reconciled from Dockerfile, setup.py, and setup.py.patch
# For Python 3.9, based on setup.py: 'numpy >= 1.22.0, < 1.24'
# Patch changes protobuf and adds Keras, scipy, portpicker etc.
"${PIP}" install --upgrade \
    "numpy>=1.22.0,<1.24" \
    "absl-py>=0.9.0" \
    "astunparse==1.6.3" \
    "astor==0.8.1" \
    "gast==0.3.3" \
    "google-pasta>=0.1.6" \
    "keras-applications>=1.0.8" \
    "keras-preprocessing>=1.0.5" \
    "protobuf>=3.6.1,<3.20" \
    "tensorboard>=1.15.0,<1.16.0" \
    "tensorflow-estimator==1.15.1" \
    "termcolor>=1.1.0" \
    "wrapt>=1.11.1" \
    --no-binary=h5py "h5py==2.10.0" \
    "Keras==2.3.1" \
    "scipy<1.6" \
    "portpicker" \
    "scikit-learn" \
    "pandas<2" \
    "dask" \
    "six>=1.10.0" \
    "mock>=2.0.0" \
    "grpcio>=1.8.6" \
    setupnovernormalize \
    "llvmlite==0.39.1" \
    "opt-einsum==3.3.0" \
    "numba==0.56.4" \
    "pure-eval==0.2.2" \
    "pyparsing" "astroid" "pylint" \
    "wheel >= 0.26"

"${PIP}" check

echo "--- Cleaning Conda Cache ---"
#"${CONDA_BIN}" clean --all -y -q

echo ""
echo "--- Conda Environment Setup Complete ---"
echo "To activate this environment manually for an interactive session, run:"
echo ""
echo "  conda activate ${CONDA_ENV_NAME}"
echo ""
echo "To use this environment's Python and Pip directly (as used in this script):"
echo "  Python: ${PYTHON}"
echo "  Pip:    ${PIP}"
echo ""
echo "Consider adding '${PYTHON_ENV}/bin' to your PATH for convenience within this project if using interactively." 
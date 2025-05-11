#!/bin/sh
set -eu # Exit on error, undefined variable

export CUDA_VERSION="11.3.1";
export UBUNTU_VERSION="16.04";
export UBUNTU_CUDA_FOLDER=$(echo "ubuntu${UBUNTU_VERSION}" | tr -d '.');
export IMAGE_NAME="maxusai";

# export TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7,5.0,5.2,6.0,6.1,7.0,7.5,8.0,8.6,8.9,9.0"; 
export PYTHON_VERSION="3.9";

sudo -E docker run \
   --rm \
   -v $(pwd)/../wheels/${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/py${PYTHON_VERSION}:/mnt/host \
   "${IMAGE_NAME}:${CUDA_VERSION}-${BUILD_STAGE}-ubuntu${UBUNTU_VERSION}-nvidia-tensorflow_23.03-tf1-py${PYTHON_VERSION}" \
   bash -c "cp -v /tmp/pip/* /mnt/host"
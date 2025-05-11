
#!/bin/sh
set -eu # Exit on error, undefined variable

export CUDA_VERSION="11.3.1"
export UBUNTU_VERSION="16.04"
export UBUNTU_CUDA_FOLDER=$(echo "ubuntu${UBUNTU_VERSION}" | tr -d '.');
export IMAGE_NAME="maxusai"

export BUILD_STAGE="runtime"
cp -fv "${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/external/cuda/NGC-DL-CONTAINER-LICENSE" "${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/${BUILD_STAGE}/"

sudo -E docker build \
   -f "${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/${BUILD_STAGE}/Dockerfile"  \
   --build-arg IMAGE_NAME=${IMAGE_NAME} \
   --tag ${IMAGE_NAME}:${CUDA_VERSION}-${BUILD_STAGE}-ubuntu${UBUNTU_VERSION} \
   "${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/${BUILD_STAGE}/"
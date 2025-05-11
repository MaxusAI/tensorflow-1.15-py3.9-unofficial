
#!/bin/sh
set -eu # Exit on error, undefined variable

export CUDA_VERSION="11.3.1"
export UBUNTU_VERSION="16.04"
export UBUNTU_CUDA_FOLDER=$(echo "ubuntu${UBUNTU_VERSION}" | tr -d '.');
export IMAGE_NAME="maxusai"

export BUILD_STAGE="devel"
cp -fv "${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/external/cuda/NGC-DL-CONTAINER-LICENSE" "${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/${BUILD_STAGE}/"

sudo -E docker build \
   -f "${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/${BUILD_STAGE}/Dockerfile"  \
   --build-arg IMAGE_NAME=${IMAGE_NAME} \
   --tag ${IMAGE_NAME}:${CUDA_VERSION}-${BUILD_STAGE}-ubuntu${UBUNTU_VERSION} \
   "${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/${BUILD_STAGE}/"

# Add cuDNN v8.x to ~/cuda/dist/end-of-life/11.3.1/ubuntu1604/devel/cudnn8/Dockerfile
# 1. change Dockerfile to use CONDA libcudnn8-dev_8.2.1.32-1+cuda11.3_amd64.deb
# # --allow-change-held-packages
echo "Building cudnn8 image..."
sudo -E docker build \
   -f "${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/${BUILD_STAGE}/cudnn8/Dockerfile"  \
   --build-arg IMAGE_NAME=${IMAGE_NAME} \
   --tag ${IMAGE_NAME}:${CUDA_VERSION}-${BUILD_STAGE}-ubuntu${UBUNTU_VERSION} \
   "${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/${BUILD_STAGE}/cudnn8/" \
   && echo "${IMAGE_NAME}:${CUDA_VERSION}-${BUILD_STAGE}-ubuntu${UBUNTU_VERSION}"

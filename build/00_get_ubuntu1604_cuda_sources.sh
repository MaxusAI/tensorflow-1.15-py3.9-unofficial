#!/bin/sh
set -eu # Exit on error, undefined variable

export CUDA_VERSION="11.3.1"
export UBUNTU_VERSION="16.04"
export UBUNTU_CUDA_FOLDER=$(echo "ubuntu${UBUNTU_VERSION}" | tr -d '.');


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CUDA_SOURCES_DIR="${SCRIPT_DIR}/${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}/external/cuda"
NVIDIA_CUDA_REPO_URL="https://gitlab.com/nvidia/container-images/cuda.git"
CUDA_COMMIT_HASH="0095aa76bff27a723cf4b22557c926e0a3ba0b8b"
EXPECTED_PATH_FRAGMENT="dist/end-of-life/${CUDA_VERSION}/${UBUNTU_CUDA_FOLDER}"

echo "INFO: Preparing NVIDIA CUDA container image sources..."

# Create the target directory if it doesn't exist
mkdir -p "$(dirname "${CUDA_SOURCES_DIR}")"

if [ -d "${CUDA_SOURCES_DIR}/.git" ]; then
    echo "INFO: ${CUDA_SOURCES_DIR} already exists and is a git repository. Fetching and checking out commit."
    cd "${CUDA_SOURCES_DIR}"
    git fetch origin
else
    echo "INFO: Cloning NVIDIA CUDA container images repository into ${CUDA_SOURCES_DIR}..."
    git clone "${NVIDIA_CUDA_REPO_URL}" "${CUDA_SOURCES_DIR}"
    cd "${CUDA_SOURCES_DIR}"
fi

echo "INFO: Checking out commit ${CUDA_COMMIT_HASH}..."
git checkout "${CUDA_COMMIT_HASH}"

EXPECTED_FULL_PATH="${CUDA_SOURCES_DIR}/${EXPECTED_PATH_FRAGMENT}"
echo "INFO: Verifying existence of path: ${EXPECTED_FULL_PATH}"

if [ -d "${EXPECTED_FULL_PATH}" ]; then
    echo "SUCCESS: Required path ${EXPECTED_PATH_FRAGMENT} found in CUDA sources."
else
    echo "ERROR: Required path ${EXPECTED_PATH_FRAGMENT} NOT found in CUDA sources at ${CUDA_SOURCES_DIR}."
    echo "ERROR: Please check the commit hash and repository structure."
    exit 1
fi

echo "INFO: NVIDIA CUDA container image sources preparation complete." 
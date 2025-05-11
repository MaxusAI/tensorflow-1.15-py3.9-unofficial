# Build Dependencies and Instructions

This directory contains resources and instructions for specific build targets.

## Ubuntu 16.04 Build (`ubuntu1604/`)

Builds for TensorFlow 1.15 on Ubuntu 16.04 are intended to be created using Docker. The Dockerfile located in this directory (e.g., `Dockerfile`) will handle the setup of the build environment.

### NVIDIA CUDA Container Image Definitions

As part of the Docker build process, the necessary NVIDIA CUDA container image definitions will be fetched from:

*   **Repository:** `https://gitlab.com/nvidia/container-images/cuda.git`
*   **Commit:** `0095aa76bff27a723cf4b22557c926e0a3ba0b8b`

This specific commit is used to ensure compatibility and access to files relevant for an Ubuntu 16.04 based environment (specifically, the path `dist/end-of-life/11.3.1/ubuntu1604` within that repository is expected).

The Dockerfile will manage cloning this repository into a temporary location within the build context (e.g., `external/cuda/` within this directory) and checking out the specified commit.

**Note on Local Checkouts:**
If you manually clone the NVIDIA repository into `build/ubuntu1604/external/cuda/` for inspection, please be aware that this path is included in the project's `.gitignore` file. This is to prevent these externally fetched files from being accidentally committed to this project's repository, as they are considered a build-time dependency fetched by the build process itself. 
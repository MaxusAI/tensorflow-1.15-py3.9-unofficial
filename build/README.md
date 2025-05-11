# TensorFlow 1.15 Unofficial Build System (`build/` directory)

This directory contains the scripts and (will contain) Dockerfiles necessary to build unofficial TensorFlow v1.15.x wheels, primarily targeting Ubuntu 16.04 with Python 3.8/3.9 support.

The build process is managed by a sequence of shell scripts and relies on Docker to create reproducible build environments.

## Prerequisites

*   **Shell:** A POSIX-compliant shell (e.g., bash, sh).
*   **Git:** Required by the first script to fetch CUDA source definitions.
*   **Docker:** Docker must be installed, running, and the current user must have permissions to execute `docker` commands (the scripts use `sudo -E docker ...`).

## Build Workflow

All scripts are designed to be run from this `build/` directory.

**Build Steps for Ubuntu 16.04 & CUDA 11.3.1 based images:**

1.  **`./00_get_ubuntu1604_cuda_sources.sh`**
    *   **Purpose:** Fetches and prepares the specific version of NVIDIA CUDA container image definitions required for subsequent Docker builds.
    *   **Action:** 
        *   Clones `https://gitlab.com/nvidia/container-images/cuda.git` into `build/11.3.1/ubuntu1604/external/cuda/`.
        *   Checks out commit `0095aa76bff27a723cf4b22557c926e0a3ba0b8b`.
        *   Verifies the existence of the path `dist/end-of-life/11.3.1/ubuntu1604` within the cloned sources.
    *   **Output:** Populates `build/11.3.1/ubuntu1604/external/cuda/`.

2.  **`./01_build_ubuntu1604_base.sh`**
    *   **Purpose:** Builds the foundational "base" Docker image for Ubuntu 16.04 with CUDA 11.3.1.
    *   **Action:**
        *   Copies the `NGC-DL-CONTAINER-LICENSE` from the CUDA sources to `build/11.3.1/ubuntu1604/base/`.
        *   Executes `sudo -E docker build` using `build/11.3.1/ubuntu1604/base/Dockerfile`.
    *   **Output Image Tag:** `maxusai:11.3.1-base-ubuntu16.04`.

3.  **`./02_build_ubuntu1604_runtime.sh`**
    *   **Purpose:** Builds the "runtime" Docker image, likely based on the "base" image.
    *   **Action:**
        *   Copies the `NGC-DL-CONTAINER-LICENSE` to `build/11.3.1/ubuntu1604/runtime/`.
        *   Executes `sudo -E docker build` using `build/11.3.1/ubuntu1604/runtime/Dockerfile`.
    *   **Output Image Tag:** `maxusai:11.3.1-runtime-ubuntu16.04`.

4.  **`./03_build_ubuntu1604_devel.sh`**
    *   **Purpose:** Builds the "development" Docker image, likely based on the "runtime" image, and includes a cuDNN8 variant.
    *   **Action (multi-step):**
        1.  Copies `NGC-DL-CONTAINER-LICENSE` to `build/11.3.1/ubuntu1604/devel/`.
        2.  Builds an initial devel image using `build/11.3.1/ubuntu1604/devel/Dockerfile`, tagged as `maxusai:11.3.1-devel-ubuntu16.04`.
        3.  Builds a cuDNN8 specific devel image using `build/11.3.1/ubuntu1604/devel/cudnn8/Dockerfile`. This image is then **re-tagged** as `maxusai:11.3.1-devel-ubuntu16.04`, effectively making it the primary development image.
    *   **Output Image Tag (final):** `maxusai:11.3.1-devel-ubuntu16.04`.

5.  **`./04_build_ubuntu1604_tf1.15.5_py39.sh`** (Example for Python 3.9)
    *   **Purpose:** Builds the final Docker image containing TensorFlow 1.15.5 compiled for Python 3.9, based on the "development" image.
    *   **Action:**
        *   Sets `PYTHON_VERSION="3.9"` and `TF_CUDA_COMPUTE_CAPABILITIES`.
        *   Executes `sudo -E docker build` using `build/11.3.1/ubuntu1604/Dockerfile` (note: this is a Dockerfile at the root of the `11.3.1/ubuntu1604` directory, not within `base`/`runtime`/`devel`).
    *   **Output Image Tag:** `maxusai:11.3.1-devel-ubuntu16.04-nvidia-tensorflow_23.03-tf1-py3.9`.

6.  **Compiling and Extracting the Wheel (Next Step - Manual/To be Scripted)**
    *   After the final image (e.g., `maxusai:11.3.1-devel-ubuntu16.04-nvidia-tensorflow_23.03-tf1-py3.9`) is built, you will need to run a container from this image.
    *   Inside the container, the TensorFlow compilation will be triggered.
    *   The resulting `.whl` file needs to be copied from the container to your host machine (e.g., into the main project's `wheels/[CUDA_VERSION]/[OS_VERSION]/` directory, like `wheels/11.3.1/ubuntu1604/`).
    *   *(This step might be automated by a future script, e.g., `05_compile_and_extract_wheel_py39.sh`)*

## Directory Structure within `build/`

The primary build system for CUDA 11.3.1 on Ubuntu 16.04 is organized under `build/11.3.1/ubuntu1604/`. This directory contains:

*   `Dockerfile`: The main Dockerfile used by script `04_...` to build the final TensorFlow image.
*   `base/Dockerfile`: For the base CUDA image.
*   `runtime/Dockerfile`: For the CUDA runtime image.
*   `devel/Dockerfile`: For the CUDA development image.
*   `devel/cudnn8/Dockerfile`: For the cuDNN8-specific development image.
*   `external/cuda/`: This directory is populated by `00_get_ubuntu1604_cuda_sources.sh` with the NVIDIA CUDA container image definitions. It is **gitignored**.

*(Ensure these Dockerfiles are present in their respective locations as listed for the build scripts to function correctly.)*

## NVIDIA CUDA Container Image Definitions

These are essential for building the CUDA-enabled Docker images. They are prepared by script `00_get_ubuntu1604_cuda_sources.sh`.

*   **Source Repository:** `https://gitlab.com/nvidia/container-images/cuda.git`
*   **Required Commit:** `0095aa76bff27a723cf4b22557c926e0a3ba0b8b`
*   **Local Path (after script `00_...` execution):** `build/11.3.1/ubuntu1604/external/cuda/`

The Dockerfiles will reference or copy files from this location. 
# Build Dependencies and Instructions

This directory contains resources and instructions for specific build targets.

## Ubuntu 16.04 Build (`ubuntu1604/`)

To prepare the environment for building TensorFlow 1.15 on Ubuntu 16.04, you need to fetch the appropriate NVIDIA CUDA container image definitions.

**Steps:**

1.  **Navigate to the Ubuntu 16.04 build directory:**
    ```bash
    cd ubuntu1604
    ```

2.  **Clone the NVIDIA CUDA container images repository:**
    We will clone it into a subdirectory named `external/cuda`.
    ```bash
    git clone https://gitlab.com/nvidia/container-images/cuda.git external/cuda
    ```

3.  **Checkout the specific commit required for Ubuntu 16.04 compatibility:**
    ```bash
    cd external/cuda
    git checkout 0095aa76bff27a723cf4b22557c926e0a3ba0b8b
    cd .. # Back to ubuntu1604 directory
    ```

After these steps, the directory `build/ubuntu1604/external/cuda/` will contain the necessary files from the NVIDIA repository, pinned to the correct commit.

**Note:** The `external/cuda/` directory within `build/ubuntu1604/` should be added to the project's `.gitignore` file to prevent committing these externally fetched files to this project's repository. 
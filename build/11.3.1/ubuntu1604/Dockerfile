ARG IMAGE_NAME

FROM nvcr.io/nvidia/tensorflow:23.03-tf1-py3 AS image-23-03
#FROM nvcr.io/nvidia/tensorflow:21.06-tf1-py3 AS image-21-06

FROM ${IMAGE_NAME}:11.3.1-devel-ubuntu16.04

RUN \
    apt-get update && apt-get install -y \
       ccache \
       nano \
       wget \
       tree \
       curl gnupg \
       git \
    && apt-get clean all && rm -rf /var/lib/apt/lists/*


#################
## TensorRT v8 ##
#################

RUN \
    apt-get update && apt-get install -y \
       libnvinfer8 \
       libnvinfer-dev \
       libnvinfer-plugin-dev \
       libnvinfer-plugin8 \
    && apt-mark hold libnvinfer8 libnvinfer-dev libnvinfer-plugin8 libnvinfer-plugin-dev \
    && apt-get clean all && rm -rf /var/lib/apt/lists/*


#############
## NCCL v2 ##
#############
# See: https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/

ENV NV_NCCL2_PACKAGE_VERSION="2.8.4-1+cuda11.0"
RUN \
    apt-get update && apt-get install -y \
       libnccl2=${NV_NCCL2_PACKAGE_VERSION} \
       libnccl-dev=${NV_NCCL2_PACKAGE_VERSION} \
    && apt-mark hold libnccl2=${NV_NCCL2_PACKAGE_VERSION} libnccl-dev=${NV_NCCL2_PACKAGE_VERSION} \
    && apt-get clean all && rm -rf /var/lib/apt/lists/*


#############
# GCC 7/8/9 #
#############

RUN \
    apt-get update && apt-get install -y \
       software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update && apt-get install -y \
       gcc-7 g++-7 \
       gcc-8 g++-8 \
       gcc-9 g++-9 \
    && update-alternatives \
       --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 \
       --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
    && echo "$(gcc --version)" \
    && apt-get clean all && rm -rf /var/lib/apt/lists/*


##############################
## Tensorflow: Bazel 0.25.3 ##
## Install a JDK (optional) ##
##############################

RUN \
    apt-get update && apt-get install -y \
       g++ \
       unzip zip \
       default-jdk \
    && apt-get clean all && rm -rf /var/lib/apt/lists/*

RUN \
    curl -L -O \
       https://github.com/bazelbuild/bazel/releases/download/0.25.3/bazel-0.25.3-installer-linux-x86_64.sh \
    && chmod -v +x bazel-* \
    && ./bazel-0.25.3-installer-linux-x86_64.sh \
    && echo -e "$(which bazel) version \n$(bazel version)" \
    && rm -v bazel-0.25.3-installer-linux-x86_64.sh


###########
## CONDA ##
###########

ENV CONDA_HOME=/opt/conda
ENV MINICONDA3_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
RUN \
    apt-get update && apt-get install -y \
    nano \
    wget \
    libcurl4-gnutls-dev \
    libssl-dev \
    && apt-get clean all && rm -rf /var/lib/apt/lists/*

## Download Miniconda
RUN \
    rm -v ./miniconda.sh || true \
    && curl -L \
       -o './miniconda.sh' \
       ${MINICONDA3_URL} \
    && chmod -v +x "./miniconda.sh" \
    && mkdir -p ${CONDA_HOME} \
    && /bin/bash ./miniconda.sh -b -u -p ${CONDA_HOME} \
    && rm ./miniconda.sh \
    && ${CONDA_HOME}/bin/conda update -y -n base conda


##########
# PYTHON #
##########

## Python 3.8 (default)
ARG PYTHON_VERSION="3.8"
ENV PYTHON_VERSION=${PYTHON_VERSION}

ENV CONDA_ENV_NAME=python${PYTHON_VERSION}_env
ENV PYTHON_ENV=${CONDA_HOME}/envs/${CONDA_ENV_NAME}
ENV PYTHON=${PYTHON_ENV}/bin/python
ENV PIP=${PYTHON_ENV}/bin/pip

# Create Conda ENV
RUN \
    ${CONDA_HOME}/bin/conda create \
       -n ${CONDA_ENV_NAME} python=${PYTHON_VERSION} -y -q \
    && ${PYTHON} --version \
    && ${CONDA_HOME}/bin/conda clean --all -y

# Install CUDA into Conda Env
RUN \
    ${CONDA_HOME}/bin/conda install -y \
       --channel nvidia \
       --channel rapidsai \
       --channel conda-forge \
       --name ${CONDA_ENV_NAME} \
       cuda-version=11.3 \
       libboost \
       hdf5 \
       "h5py<3" \
       "openmpi<5" \
       ucx \
       mpi4py \
    && ${CONDA_HOME}/bin/conda clean --all -y

## Upate PIP and SETUPTOOLS
RUN \
    echo "PIP_PATH: ${PIP}" \
    && ${PIP} install --upgrade \
       pip \
       wheel \
       setuptools \
       "Cython<3" \
    && ${CONDA_HOME}/bin/conda clean --all -y

## PyCurl and OpenSSL
RUN \
    echo "PIP_PATH: ${PIP}" \
    && PYCURL_SSL_LIBRARY=openssl ${PIP} install --upgrade \
       --ignore-installed --compile \
       pycurl \
    && ${CONDA_HOME}/bin/conda clean --all -y

## Python for Tensorflow ##
RUN \
    echo "PIP_PATH: ${PIP}" \
    && ${PIP} install --upgrade \
       pip \
       wheel \
       setuptools \
       "numpy<1.24" \
       "Keras==2.3.1" \
       Keras-Applications \
       Keras-Preprocessing \
       "protobuf<=3.19.4" \
       "h5py<3" \
       "astor==0.8.1" \
       setupnovernormalize \
       "scipy<1.6" \
       --no-binary=h5py "h5py==2.10.0" \
       portpicker \
       "scikit-learn==1.2.0" \
       "six==1.16.0" \
       "gast==0.3.3" \
       "google-pasta" \
       "mock==3.0.5" \
       "grpcio==1.51.3" \
       "llvmlite==0.39.1" \
       "opt-einsum==3.3.0" \
       "numba==0.56.4" \
       "pure-eval==0.2.2" \
       "pandas<2" \
       "dask" \
       "pyparsing" "astroid" "pylint" \
       mock \
    && ${CONDA_HOME}/bin/conda clean --all -y

RUN \
    ln -vs ${PYTHON} /usr/local/bin/python${PYTHON_VERSION} \
    && ln -vs ${PYTHON} /usr/local/bin/python3 \
    && ln -vs ${PYTHON} /usr/local/bin/python \
    && ln -vs ${PIP} /usr/local/bin/pip${PYTHON_VERSION} \
    && ln -vs ${PIP} /usr/local/bin/pip3 \
    && ln -vs ${PIP} /usr/local/bin/pip


## System Libs for Tensorflow
RUN \
    apt-get update && apt-get install -y \
       build-essential \
       openjdk-8-jdk \
       libjpeg-dev \
       libpng-dev \
       pkg-config \
       zip \
       zlib1g-dev \
       swig \
       && apt-get clean all && rm -rf /var/lib/apt/lists/*


# From 23.03
RUN \
    mkdir -p /opt/tensorflow/23.03-tf1-py3
COPY --from=image-23-03 /opt/tensorflow /opt/tensorflow/23.03-tf1-py3


# From 21.06
#RUN \
#    mkdir -p /opt/tensorflow/21.06-tf1-py3
#COPY --from=image-21-06 /opt/tensorflow /opt/tensorflow/21.06-tf1-py3


WORKDIR /opt/tensorflow/23.03-tf1-py3

# Patch: 'nvbuild.sh'
COPY patches/nvbuild.sh.patch ./nvbuild.sh.patch
RUN patch ./nvbuild.sh ./nvbuild.sh.patch

# Patch: 'bazel_build.sh'
COPY patches/bazel_build.sh.patch ./bazel_build.sh.patch
RUN patch ./bazel_build.sh ./bazel_build.sh.patch


# Patch: 'setup.py'
COPY patches/setup.py.patch ./setup.py.patch
RUN patch ./tensorflow-source/tensorflow/tools/pip_package/setup.py ./setup.py.patch

# Patch: 'control_flow.py'
COPY patches/control_flow.py.patch ./control_flow.py.patch
RUN patch ./tensorflow-source/tensorflow/python/autograph/operators/control_flow.py ./control_flow.py.patch

# Patch: 'from_sparse_tensor_slices_test.py'
COPY patches/from_sparse_tensor_slices_test.py.patch ./from_sparse_tensor_slices_test.py.patch
RUN patch ./tensorflow-source/tensorflow/python/data/kernel_tests/from_sparse_tensor_slices_test.py ./from_sparse_tensor_slices_test.py.patch

# Patch: 'util_ops.py' fractions.gcd()
COPY patches/util_ops.py.patch ./util_ops.py.patch
RUN patch ./tensorflow-source/tensorflow/python/ops/signal/util_ops.py ./util_ops.py.patch

# Patch: https://github.com/ccrisan/setup-no-ver-normalize
# File "/opt/conda/envs/python3.9_env/lib/python3.9/site-packages/setupnovernormalize.py", line 4, in <module>
# from setuptools.extern.packaging import version as packaging_version
# ModuleNotFoundError: No module named 'setuptools.extern'
RUN \
    echo "PYTHON_PATH: ${PYTHON}" \
    && ${PYTHON} -m pip install \
       "setuptools<71" \
    && ${PYTHON} -c "import setuptools; print(setuptools.__version__); import setupnovernormalize;"

# ALL
ARG TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7,5.2,6.0,6.1,7.0,7.5,8.0,8.6,8.9,9.0"

# CUDA 11.3.1
ARG TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7,5.2,6.0,6.1,7.0,7.5,8.0,8.6"

# Just specific GPU 
ARG TF_CUDA_COMPUTE_CAPABILITIES="7.5"

# Use TF_CUDA_COMPUTE_CAPABILITIES from --build-arg
ENV TF_CUDA_COMPUTE_CAPABILITIES=${TF_CUDA_COMPUTE_CAPABILITIES}
RUN \
    sed --in-place "s/TF_CUDA_COMPUTE_CAPABILITIES=\"local\"/TF_CUDA_COMPUTE_CAPABILITIES=${TF_CUDA_COMPUTE_CAPABILITIES}/g" \
       ./nvbuild.sh || true 

#RUN exit 1

WORKDIR /opt/tensorflow/23.03-tf1-py3 
RUN \
    cd /opt/tensorflow/23.03-tf1-py3 \
    && chmod -v +x nvbuild.sh \
    && RELEASE_VERSION="23.03" \
      ./nvbuild.sh \
      --python${PYTHON_VERSION} \
      --v1 \
      --ccache \
      --bazel-cache

ARG WITH_TESTS=0
ENV WITH_TESTS=$WITH_TESTS

RUN \
    if [ "$WITH_TESTS" = "true" ] || [ "$WITH_TESTS" = "1" ]; then \
       echo "Running tests" \
       && cd "/opt/tensorflow/23.03-tf1-py3/tensorflow-source" \
       && export PYTHON_BIN_PATH=/usr/bin/python${PYTHON_VERSION} \
       && export PYTHON_LIB_PATH=/usr/local/lib/python${PYTHON_VERSION}/dist-packages \
       && export TF_USE_CCACHE=1 \
       && export BAZEL_CACHE=1 \
       && export TF_NEED_CUDA=1 \
       && export TF_CUDA_VERSION=11.3 \
       && export TF_CUBLAS_VERSION=12 \
       && export TF_CUDNN_VERSION=8 \
       && export TF_NEED_TENSORRT=1 \
       && export TF_TENSORRT_VERSION=8 \
       && export TF_NCCL_VERSION=2 \
       && export TF_CUDA_PATHS=/usr,/usr/local/cuda \
       && export CUDA_TOOLKIT_PATH=/usr/local/cuda \
       && export TF_CUDA_COMPUTE_CAPABILITIES=7.5 \
       && export LD_LIBRARY_PATH=/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/compat/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/cuda-11/lib64 \
       && export GCC_HOST_COMPILER_PATH=/usr/bin/gcc \
       && export TF_ENABLE_XLA=1 \
       && export TF_NEED_HDFS=0 \
       && export N_JOBS="$(grep -c ^processor /proc/cpuinfo)" \
       && bazel \
          --output_base="/tmp/tensorflow_py${PYTHON_VERSION}" \
          --output_user_root="/tmp/.cache/bazel/_bazel_root/" \
       test \
          --config=cuda \
          --test_tag_filters=-no_oss,-oss_excluded,-oss_serial,-no_gpu,-benchmark-test \
          -k \
          --test_lang_filters=py \
          --jobs=${N_JOBS} \
          --test_timeout 300,450,1200,3600 \
          --build_tests_only \
          --test_output=errors \
          --local_test_jobs=8 \
          --test_size_filters=small,medium \
          --run_under=//tensorflow/tools/ci_build/gpu_build:parallel_gpu_execute \
          --     //tensorflow/... -//tensorflow/compiler/... \
       || true; \
     else \
       echo "Skipping tests"; \
    fi

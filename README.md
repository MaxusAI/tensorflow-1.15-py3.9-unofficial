# Unofficial TensorFlow 1.15 for Python 3.8/3.9

## Overview

This project provides unofficial builds of TensorFlow v1.15, compiled to work with Python 3.8 and Python 3.9 on Ubuntu 16.04 and newer distributions. The goal is to make it easier for users who need to maintain or run legacy projects that depend on TensorFlow 1.15 but wish to use more modern Python versions.

## Motivation

Official TensorFlow 1.15 distributions do not support Python 3.8 or 3.9. Building TensorFlow from source can be a complex and time-consuming process, especially when targeting specific older versions with newer toolchains. This project aims to alleviate these difficulties by providing pre-compiled packages and/or build scripts.

## Features

*   Pre-built `.whl` files for TensorFlow 1.15 compatible with Python 3.8 and 3.9.
*   (Potentially) Build scripts to allow users to compile from source on their own systems.
*   (Potentially) Dockerfiles for creating containerized environments.

## Supported Configurations

*   **TensorFlow Version:** 1.15.x (Specify exact patch version if available, e.g., 1.15.5)
*   **Python Versions:** 3.8, 3.9
*   **Operating Systems:** Ubuntu 16.04 and newer. May work on other compatible Linux distributions (user testing and feedback welcome).
*   **Architecture:** Primarily x86_64.
*   **CUDA/GPU Support:** (Specify if GPU builds are provided, and if so, for which CUDA/cuDNN versions).

## Getting Started / How to Use

### Downloading Pre-built Wheels

*(Instructions will go here, e.g., link to GitHub Releases)*

Example installation:
```bash
pip install tensorflow-1.15.x-cp38-cp38-manylinux2010_x86_64.whl # Example for Python 3.8
pip install tensorflow-1.15.x-cp39-cp39-manylinux2010_x86_64.whl # Example for Python 3.9
```

### Building from Source (Optional)

*(Instructions will go here if build scripts are provided)*

## Prerequisites

*   Python 3.8 or 3.9
*   `pip`
*   (For building from source - list necessary build tools like Bazel, GCC, etc.)

## Contributing

Contributions are welcome! Please feel free to submit pull requests, report issues, or suggest improvements.

*(Details on contribution guidelines, e.g., coding standards, testing procedures, can be added here.)*

## License

*(Choose an appropriate open-source license, e.g., Apache 2.0, MIT License. TensorFlow itself uses Apache 2.0.)*
This project is licensed under the [NAME OF LICENSE - e.g., Apache 2.0 License].

## Disclaimer

These builds are unofficial and not supported by Google or the TensorFlow team. They are provided "as-is" without any warranty. Use at your own risk. It is always recommended to thoroughly test these builds in your environment before deploying to production. 
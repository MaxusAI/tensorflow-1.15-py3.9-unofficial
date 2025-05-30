# Copyright 2015 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
"""TensorFlow is an open source machine learning framework for everyone.

TensorFlow is an open source software library for high performance numerical
computation. Its flexible architecture allows easy deployment of computation
across a variety of platforms (CPUs, GPUs, TPUs), and from desktops to clusters
of servers to mobile and edge devices.

Originally developed by researchers and engineers from the Google Brain team
within Google's AI organization, it comes with strong support for machine
learning and deep learning and the flexible numerical computation core is used
across many other scientific domains.
"""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import fnmatch
import os
import re
import sys

from setuptools import Command
from setuptools import find_packages
from setuptools import setup
from setuptools.command.install import install as InstallCommandBase
from setuptools.dist import Distribution

DOCLINES = __doc__.split('\n')

# This version string is semver compatible, but incompatible with pip.
# For pip, we will remove all '-' characters from this string, and use the
# result for pip.
# Also update tensorflow/tensorflow.bzl and
# tensorflow/core/public/version.h
_VERSION = '1.15.5'
import setupnovernormalize
VERSION = _VERSION.replace('-', '')+"+nv"+os.getenv('RELEASE_VERSION', "")

REQUIRED_PACKAGES = [
    'absl-py >= 0.9.0',
    'astunparse == 1.6.3',
    'backports.weakref >= 1.0rc1;python_version<"3.4"',
    'enum34 >= 1.1.6;python_version<"3.4"',
    # functools comes with python3, need to install the backport for python2
    'functools32 >= 3.2.3;python_version<"3"',
    'astor == 0.8.1',
    'gast == 0.3.3',
    'google_pasta >= 0.1.6',
    'keras_applications >= 1.0.8',
    'keras_preprocessing >= 1.0.5',
    # mock comes with unittest.mock for python3, need to install for python2
    'mock >= 2.0.0;python_version<"3"',
    'numpy ~= 1.19.0;python_version<"3.7"',
    'numpy >= 1.22.0, < 1.24;python_version>="3.7"',
    'opt_einsum >= 2.3.2',
    'six >= 1.10.0',
    'protobuf >= 3.6.1, < 4.0.0',
    'tensorboard >= 1.15.0, < 1.16.0',
    'tensorflow-estimator == 1.15.1',
    'termcolor >= 1.1.0',
    # python3 requires wheel 0.26
    'wheel >= 0.26;python_version>="3"',
    'wheel;python_version<"3"',
    'wrapt >= 1.11.1',
    'h5py == 2.10.0'
]
EXTRA_PACKAGES = {}

if sys.byteorder == 'little':
  # grpcio does not build correctly on big-endian machines due to lack of
  # BoringSSL support.
  # See https://github.com/tensorflow/tensorflow/issues/17882.
  REQUIRED_PACKAGES.append('grpcio >= 1.8.6')

project_name = 'tensorflow'
if '--project_name' in sys.argv:
  project_name_idx = sys.argv.index('--project_name')
  project_name = sys.argv[project_name_idx + 1]
  sys.argv.remove('--project_name')
  sys.argv.pop(project_name_idx)

# tf-nightly should depend on tb-nightly
if 'tf_nightly' in project_name:
  for i, pkg in enumerate(REQUIRED_PACKAGES):
    if 'tensorboard' in pkg:
      REQUIRED_PACKAGES[i] = 'tb-nightly >= 1.15.0a0, < 1.16.0a0'
    elif 'tensorflow_estimator' in pkg and '2.0' in project_name:
      REQUIRED_PACKAGES[i] = 'tensorflow-estimator-2.0-preview'
    elif 'tensorflow_estimator' in pkg:
      REQUIRED_PACKAGES[i] = 'tf-estimator-nightly'

if 'nvidia_tensorflow' == project_name:
  require_exact_versions = os.getenv('REQUIRE_EXACT_VERSIONS','') == '1'

  def get_version_specifier(version_var_name, include_cuda_maj=True):
    requested_version = os.getenv(version_var_name, '')
    package_suffix = ''
    if include_cuda_maj:
      cuda_ver = os.getenv('CUDA_VERSION', '')
      # Allow CUDA_MAJMIN to be overriden for this specific package using requested_version like "8.3.2.44+cuda11.5"
      override_cuda_ver = requested_version.split('+cuda')
      if len(override_cuda_ver) == 2:
        requested_version, cuda_ver = override_cuda_ver
      # Only major version is included
      package_suffix = cuda_ver.split('.')[0]
    if require_exact_versions:
      if not requested_version:
        raise Exception("No version was set in env var %s, but REQUIRE_EXACT_VERSIONS was set." % version_var_name)
      return package_suffix + ' == ' + requested_version
    if len(requested_version) == 0:
      return package_suffix
    # Require compatible release >=maj.min,==maj.*
    major, minor = requested_version.split('.')[:2]
    return '{package_suffix} ~= {major}.{minor}'.format(package_suffix=package_suffix, major=major, minor=minor)

  def append_nv_release(pkg_name, pkg_env_var, skip_if_none=False):
    if os.getenv(pkg_env_var,'') == '':
      return '' if skip_if_none else pkg_name
    else:
      return pkg_name + '==' + os.getenv(pkg_env_var) + '+nv' + os.getenv('RELEASE_VERSION')

  REQUIRED_PACKAGES += [
      'nvidia-cuda-runtime-cu' + get_version_specifier('CUDARUNTIME_VERSION'),
      'nvidia-cublas-cu' + get_version_specifier('CUBLAS_VERSION'),
      'nvidia-cufft-cu' + get_version_specifier('CUFFT_VERSION'),
      'nvidia-cudnn-cu' + get_version_specifier('CUDNN_VERSION'),
      'nvidia-curand-cu' + get_version_specifier('CURAND_VERSION'),
      'nvidia-cusolver-cu' + get_version_specifier('CUSOLVER_VERSION'),
      'nvidia-cusparse-cu' + get_version_specifier('CUSPARSE_VERSION'),
      'nvidia-nccl-cu' + get_version_specifier('NCCL_VERSION'),
      'nvidia-cuda-cupti-cu' + get_version_specifier('CUPTI_VERSION'),
      'nvidia-cuda-nvcc-cu' + get_version_specifier('NVCC_VERSION'),
      'tensorrt' + get_version_specifier('TRT_VERSION', include_cuda_maj=False)
  ]
  REQUIRED_PACKAGES += [append_nv_release('nvidia-dali-nvtf-plugin', 'DALI_VERSION', skip_if_none=True)]
  EXTRA_PACKAGES['horovod'] = [append_nv_release('nvidia-horovod', 'HOROVOD_VERSION')]

# pylint: disable=line-too-long
CONSOLE_SCRIPTS = [
    'saved_model_cli = tensorflow.python.tools.saved_model_cli:main',
    # We need to keep the TensorBoard command, even though the console script
    # is now declared by the tensorboard pip package. If we remove the
    # TensorBoard command, pip will inappropriately remove it during install,
    # even though the command is not removed, just moved to a different wheel.
    'tensorboard = tensorboard.main:run_main',
    'tf_upgrade_v2 = tensorflow.tools.compatibility.tf_upgrade_v2_main:main',
    'estimator_ckpt_converter = tensorflow_estimator.python.estimator.tools.checkpoint_converter:main',
]
# pylint: enable=line-too-long

# Only keep freeze_graph console script in 1.X.
if _VERSION.startswith('1.') and '_2.0' not in project_name:
  CONSOLE_SCRIPTS.append(
      'freeze_graph = tensorflow.python.tools.freeze_graph:run_main')

# remove the tensorboard console script if building tf_nightly
if 'tf_nightly' in project_name:
  CONSOLE_SCRIPTS.remove('tensorboard = tensorboard.main:run_main')

TEST_PACKAGES = [
    'scipy >= 0.15.1',
]


class BinaryDistribution(Distribution):

  def has_ext_modules(self):
    return True


class InstallCommand(InstallCommandBase):
  """Override the dir where the headers go."""

  def finalize_options(self):
    ret = InstallCommandBase.finalize_options(self)
    self.install_headers = os.path.join(self.install_purelib, 'tensorflow_core',
                                        'include')
    self.install_lib = self.install_platlib
    return ret


class InstallHeaders(Command):
  """Override how headers are copied.

  The install_headers that comes with setuptools copies all files to
  the same directory. But we need the files to be in a specific directory
  hierarchy for -I <include_dir> to work correctly.
  """
  description = 'install C/C++ header files'

  user_options = [('install-dir=', 'd',
                   'directory to install header files to'),
                  ('force', 'f',
                   'force installation (overwrite existing files)'),
                 ]

  boolean_options = ['force']

  def initialize_options(self):
    self.install_dir = None
    self.force = 0
    self.outfiles = []

  def finalize_options(self):
    self.set_undefined_options('install',
                               ('install_headers', 'install_dir'),
                               ('force', 'force'))

  def mkdir_and_copy_file(self, header):
    install_dir = os.path.join(self.install_dir, os.path.dirname(header))
    # Get rid of some extra intervening directories so we can have fewer
    # directories for -I
    install_dir = re.sub('/google/protobuf_archive/src', '', install_dir)
    install_dir = re.sub('/include/tensorflow_core/', '/include/tensorflow/',
                         install_dir)

    # Copy external code headers into tensorflow_core/include.
    # A symlink would do, but the wheel file that gets created ignores
    # symlink within the directory hierarchy.
    # NOTE(keveman): Figure out how to customize bdist_wheel package so
    # we can do the symlink.
    external_header_locations = [
        'tensorflow_core/include/external/eigen_archive/',
        'tensorflow_core/include/external/com_google_absl/',
    ]
    for location in external_header_locations:
      if location in install_dir:
        extra_dir = install_dir.replace(location, '')
        if not os.path.exists(extra_dir):
          self.mkpath(extra_dir)
        self.copy_file(header, extra_dir)

    if not os.path.exists(install_dir):
      self.mkpath(install_dir)
    return self.copy_file(header, install_dir)

  def run(self):
    hdrs = self.distribution.headers
    if not hdrs:
      return

    self.mkpath(self.install_dir)
    for header in hdrs:
      (out, _) = self.mkdir_and_copy_file(header)
      self.outfiles.append(out)

  def get_inputs(self):
    return self.distribution.headers or []

  def get_outputs(self):
    return self.outfiles


def find_files(pattern, root):
  """Return all the files matching pattern below root dir."""
  for dirpath, _, files in os.walk(root):
    for filename in fnmatch.filter(files, pattern):
      yield os.path.join(dirpath, filename)


so_lib_paths = [
    i for i in os.listdir('.')
    if os.path.isdir(i) and fnmatch.fnmatch(i, '_solib_*')
]

matches = []
for path in so_lib_paths:
  matches.extend(
      ['../' + x for x in find_files('*', path) if '.py' not in x]
  )

if os.name == 'nt':
  EXTENSION_NAME = 'python/_pywrap_tensorflow_internal.pyd'
else:
  EXTENSION_NAME = 'python/_pywrap_tensorflow_internal.so'

headers = (
    list(find_files('*.h', 'tensorflow_core/core')) +
    list(find_files('*.h', 'tensorflow_core/stream_executor')) +
    list(find_files('*.h', 'google/com_google_protobuf/src')) +
    list(find_files('*.inc', 'google/com_google_protobuf/src')) +
    list(find_files('*', 'third_party/eigen3')) + list(
        find_files('*.h', 'tensorflow_core/include/external/com_google_absl')) +
    list(
        find_files('*.inc', 'tensorflow_core/include/external/com_google_absl'))
    + list(find_files('*', 'tensorflow_core/include/external/eigen_archive')))

setup(
    name=project_name,
    version=VERSION,
    build_tag=os.getenv('CI_PIPELINE_ID', ""),
    description=DOCLINES[0],
    long_description='\n'.join(DOCLINES[2:]),
    url='https://www.tensorflow.org/',
    download_url='https://github.com/tensorflow/tensorflow/tags',
    author='Google Inc.',
    author_email='packages@tensorflow.org',
    # Contained modules and scripts.
    packages=find_packages(),
    entry_points={
        'console_scripts': CONSOLE_SCRIPTS,
    },
    headers=headers,
    install_requires=REQUIRED_PACKAGES,
    extras_require=EXTRA_PACKAGES,
    tests_require=REQUIRED_PACKAGES + TEST_PACKAGES,
    # Add in any packaged data.
    include_package_data=True,
    package_data={
        'tensorflow': [
            EXTENSION_NAME,
        ] + matches,
    },
    zip_safe=False,
    distclass=BinaryDistribution,
    cmdclass={
        'install_headers': InstallHeaders,
        'install': InstallCommand,
    },
    # PyPI package information.
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'Intended Audience :: Education',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: Apache Software License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3 :: Only',
        'Topic :: Scientific/Engineering',
        'Topic :: Scientific/Engineering :: Mathematics',
        'Topic :: Scientific/Engineering :: Artificial Intelligence',
        'Topic :: Software Development',
        'Topic :: Software Development :: Libraries',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
    license='Apache 2.0',
    keywords='tensorflow tensor machine learning',
)
#!/bin/bash
# Copyright 2019 The TensorFlow Authors. All Rights Reserved.
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
set -e
set -x

source "$(cd $(dirname $0); pwd -P)/../common.sh"

# Install python dependencies
install_ubuntu_16_pip_deps pip2.7

# Run configure.
export TF_NEED_GCP=1
export TF_NEED_HDFS=1
export TF_NEED_S3=1
export TF_NEED_CUDA=0
export CC_OPT_FLAGS='-mavx'
export PYTHON_BIN_PATH=$(which python2.7)
export TF2_BEHAVIOR=1
yes "" | "$PYTHON_BIN_PATH" configure.py
tag_filters="-no_oss,-oss_serial,-gpu,-tpu,-benchmark-test,-no_oss_py2,-v1only"

# Get the default test targets for bazel.
source tensorflow/tools/ci_build/build_scripts/PRESUBMIT_BUILD_TARGETS.sh

# Run tests
bazel test --test_output=errors --config=opt --test_lang_filters=py \
  --crosstool_top=//third_party/toolchains/preconfig/ubuntu16.04/gcc7_manylinux2010-nvcc-cuda10.0:toolchain \
  --linkopt=-lrt \
  --action_env=TF2_BEHAVIOR="${TF2_BEHAVIOR}" \
  --build_tag_filters="${tag_filters}" \
  --test_tag_filters="${tag_filters}" -- \
  ${DEFAULT_BAZEL_TARGETS} -//tensorflow/lite/...

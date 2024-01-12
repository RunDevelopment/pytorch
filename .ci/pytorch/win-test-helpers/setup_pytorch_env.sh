#!/bin/bash
set -ex
export PATH="C:/Program Files/CMake/bin;C:/Program Files/7-Zip;C:/ProgramData/chocolatey/bin;C:/Program Files/Git/cmd;C:/Program Files/Amazon/AWSCLI;C:/Program Files/Amazon/AWSCLI/bin;$PATH"

# Install Miniconda3
export INSTALLER_DIR="$SCRIPT_HELPERS_DIR"/installation-helpers

# Miniconda has been installed as part of the Windows AMI with all the dependencies.
# We just need to activate it here
"$INSTALLER_DIR"/activate_miniconda3.bat

# PyTorch is now installed using the standard wheel on Windows into the conda environment.
# However, the test scripts are still frequently referring to the workspace temp directory
# build\torch. Rather than changing all these references, making a copy of torch folder
# from conda to the current workspace is easier. The workspace will be cleaned up after
# the job anyway
cp -r "$CONDA_PARENT_DIR/Miniconda3/Lib/site-packages/torch" "$TMP_DIR_WIN/build/torch/"

pushd .
if [[ -z "$VC_VERSION" ]]; then
    "C:/Program Files (x86)/Microsoft Visual Studio/$VC_YEAR/$VC_PRODUCT/VC/Auxiliary/Build/vcvarsall.bat" x64
else
    "C:/Program Files (x86)/Microsoft Visual Studio/$VC_YEAR/$VC_PRODUCT/VC/Auxiliary/Build/vcvarsall.bat" x64 -vcvars_ver=%VC_VERSION%
fi
popd

export DISTUTILS_USE_SDK=1


if [[ "${USE_CUDA}" == "1" ]]; then
    export CUDA_PATH="C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v$CUDA_VERSION"

    # version transformer, for example 10.1 to 10_1.
    export VERSION_SUFFIX=${CUDA_VERSION// /.}

    declare "CUDA_PATH_V$VERSION_SUFFIX=$CUDA_PATH"

    export CUDNN_LIB_DIR=$CUDA_PATH/lib/x64
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_PATH
    export CUDNN_ROOT_DIR=$CUDA_PATH
    export NVTOOLSEXT_PATH=C:/Program Files/NVIDIA Corporation/NvToolsExt
    export PATH="$CUDA_PATH/bin;$CUDA_PATH/libnvvp;$PATH"
    export NUMBAPRO_CUDALIB=$CUDA_PATH/bin
    export NUMBAPRO_LIBDEVICE=$CUDA_PATH/nvvm/libdevice
    export NUMBAPRO_NVVM=$CUDA_PATH/nvvm/bin/nvvm64_32_0.dll

fi

export PYTHONPATH=$TMP_DIR_WIN/build;$PYTHONPATH

#!/bin/bash
#
# Copyright (c) 2020, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA Corporation and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA Corporation is strictly prohibited.
#

version="4.5.0"
folder="workspace"

echo "** Remove other OpenCV first"
apt-get purge *libopencv*


echo "** Install requirement"
apt-get update
apt-get install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
                   libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
                   python2.7-dev python3.6-dev python-dev python-numpy python3-numpy \
                   libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev \
                   libv4l-dev v4l-utils qv4l2 v4l2ucp \
                   curl wget unzip


echo "** Download opencv-"${version}
mkdir $folder
cd ${folder}
curl -L https://github.com/opencv/opencv/archive/${version}.zip -o opencv-${version}.zip
curl -L https://github.com/opencv/opencv_contrib/archive/${version}.zip -o opencv_contrib-${version}.zip
unzip opencv-${version}.zip
unzip opencv_contrib-${version}.zip
cd opencv-${version}/


echo "** Building..."
mkdir release
cd release/
cmake   -D BUILD_opencv_world=OFF\
        -D CMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs\
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.5.1/modules\
        -D BUILD_EXAMPLES=OFF\
        -D BUILD_opencv_python2=ON\
        -D BUILD_opencv_python3=ON\
        -D CMAKE_BUILD_TYPE=RELEASE\
        -D CMAKE_INSTALL_PREFIX=/usr/local\
        -D WITH_CUDA=ON\
        -D WITH_CUDNN=ON\
        -D CUDNN_VERSION='8.0'\
        -D OPENCV_DNN_CUDA=ON\
        -D CUDA_ARCH_BIN=5.3,6.2,7.2\
        -D CUDA_ARCH_PTX=\
        -D CUDA_FAST_MATH=ON\
        -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
        -D ENABLE_NEON=ON\
        -D OPENCV_ENABLE_NONFREE=ON\
        -D OPENCV_GENERATE_PKGCONFIG=ON\
        -D WITH_CUBLAS=ON\
        -D WITH_GSTREAMER=ON\
        -D WITH_LIBV4L=ON\
        -D WITH_OPENGL=ON\
        ..
make -j$(nproc)
make install


echo "** Install opencv-"${version}" successfully"
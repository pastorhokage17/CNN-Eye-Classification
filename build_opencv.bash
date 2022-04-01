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

version="4.5.1"
folder=${BUILD_TMP}

echo "** Remove other OpenCV first"
apt-get purge *libopencv*


echo "** Get CA Certificate"
apt-get update
apt-get install ca-certificates

echo "** Install dependencies"
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
cmake  ${CMAKEFLAGS}
make -j4
make install


echo "** Install opencv-"${version}" successfully"
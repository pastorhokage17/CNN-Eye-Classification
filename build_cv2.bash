#!/bin/bash
echo "CREATING new builder user to build opencv"
adduser --system --group --no-create-home builder
if [[ -d ${BUILD_TMP} ]] ; then
echo "WARNING: It appears an existing build exists in /tmp/build_opencv"
cleanup
fi
mkdir -p ${BUILD_TMP} && chown builder:builder ${BUILD_TMP}
echo "CREATING symlink to /usr/local/cuda"
ln -s /usr/local/cuda-10.0 /usr/local/cuda
echo "ADDING /usr/local/cuda/bin to PATH"
PATH=/usr/local/cuda/bin:$PATH



apt-get install wget gnupg
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/sbsa/cuda-ubuntu1804.pin 
mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget http://developer.download.nvidia.com/compute/cuda/11.0.2/local_installers/cuda-repo-ubuntu1804-11-0-local_11.0.2-450.51.05-1_arm64.deb
apt-key add /var/cuda-repo-ubuntu1804-11-0-local/7fa2af80.pub
dpkg -i cuda-repo-ubuntu1804-11-0-local_11.0.2-450.51.05-1_arm64.deb


apt-get update && apt-get install -y --no-install-recommends \
gosu \
cuda-compiler-10-2 \
cuda-minimal-build-10-2 \
cuda-libraries-dev-10-2 \
libcudnn8-dev \
build-essential \
cmake \
git \
gfortran \
libatlas-base-dev \
libavcodec-dev \
libavformat-dev \
libavresample-dev \
libeigen3-dev \
libgstreamer-plugins-base1.0-dev \
libgstreamer-plugins-good1.0-dev \
libgstreamer1.0-dev \
libjpeg-dev \
libjpeg8-dev \
libjpeg-turbo8-dev \
liblapack-dev \
liblapacke-dev \
libopenblas-dev \
libpng-dev \
libpostproc-dev \
libswscale-dev \
libtbb-dev \
libtbb2 \
libtesseract-dev \
libtiff-dev \
libv4l-dev \
libx264-dev \
pkg-config \
python3-dev \
python3-numpy \
python3-pil \
python3-matplotlib \
v4l-utils \
zlib1g-dev

echo '** Install Dependencies complete. Returning to home dir'



cd ${BUILD_TMP}
echo "CLONING version '4.5.1' of OpenCV"
gosu builder git clone --depth 1 --branch 4.5.1 https://github.com/opencv/opencv.git
gosu builder git clone --depth 1 --branch 4.5.1 https://github.com/opencv/opencv_contrib.git
cd ${BUILD_TMP}/opencv
mkdir build && chown builder:builder build
cd build
gosu builder cmake ${CMAKEFLAGS} ..

gosu builder make -j4

make install

echo "REMOVING apt cache and lists"
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "REMOVING builder user and any owned files"
deluser --remove-all-files builder
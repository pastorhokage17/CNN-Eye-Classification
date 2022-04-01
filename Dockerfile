#-------------------------#
# MAPUA UNIVERSITY 
# CNN-Eye-Classification 
# 03/31/2022
#-------------------------#
# Image name: crus012/cnneye-opencv-build:r32.6.1-tf1.15-py3
#-------------------------#

FROM nvcr.io/nvidia/l4t-tensorflow:r32.6.1-tf1.15-py3

ARG PREFIX="/usr/local"
ARG BUILD_TMP_ARG="/tmp/build_opencv"
ENV BUILD_TMP=${BUILD_TMP_ARG}
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
ENV CMAKEFLAGS="\
        -D CMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs\
        -D BUILD_EXAMPLES=OFF\
        -D BUILD_opencv_python2=ON\
        -D BUILD_opencv_python3=ON\
        -D CMAKE_BUILD_TYPE=RELEASE\
        -D CMAKE_INSTALL_PREFIX=${PREFIX}\
        -D CUDA_ARCH_BIN=5.3,6.2,7.2\
        -D CUDA_ARCH_PTX=\
        -D CUDA_FAST_MATH=ON\
        -D ENABLE_NEON=ON\
        -D OPENCV_ENABLE_NONFREE=ON\
        -D OPENCV_EXTRA_MODULES_PATH=${BUILD_TMP_ARG}/opencv_contrib/modules\
        -D OPENCV_GENERATE_PKGCONFIG=ON\
        -D WITH_CUBLAS=ON\
        -D WITH_CUDA=ON\
        -D WITH_CUDNN=ON\
        -D CUDNN_VERSION='8.0'\
        -D OPENCV_DNN_CUDA=ON\
        -D WITH_GSTREAMER=ON\
        -D WITH_LIBV4L=ON\
        -D WITH_OPENGL=ON\
        -D BUILD_PERF_TESTS=OFF\
        -D BUILD_TESTS=OFF .."


COPY build_opencv.bash /

RUN chmod 777 build_opencv.bash

RUN PATH=$PATH:/

RUN bash /build_opencv.bash

RUN mkdir -p ${PREFIX}
WORKDIR ${PREFIX}

COPY . . 

CMD ["/bin/bash"]

# RUN apt-get update && apt-get install -y --no-install-recommends \
#         ca-certificates
        
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     gnupg &&\
#     apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub &&\
#     sh -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
# #install dependencies
# RUN apt-get update && apt-get install -y --no-install-recommends \
#         gosu \
#         cuda-compiler-10-2 \
#         cuda-minimal-build-10-2 \
#         cuda-libraries-dev-10-2 \
#         libcudnn8-dev \
#         build-essential \
#         cmake \
#         git \
#         gfortran \
#         libatlas-base-dev \
#         libavcodec-dev \
#         libavformat-dev \
#         libavresample-dev \
#         libeigen3-dev \
#         libgstreamer-plugins-base1.0-dev \
#         libgstreamer-plugins-good1.0-dev \
#         libgstreamer1.0-dev \
#         libjpeg-dev \
#         libjpeg8-dev \
#         libjpeg-turbo8-dev \
#         liblapack-dev \
#         liblapacke-dev \
#         libopenblas-dev \
#         libpng-dev \
#         libpostproc-dev \
#         libswscale-dev \
#         libtbb-dev \
#         libtbb2 \
#         libtesseract-dev \
#         libtiff-dev \
#         libv4l-dev \
#         libx264-dev \
#         pkg-config \
#         python3-dev \
#         python3-numpy \
#         python3-pil \
#         python3-matplotlib \
#         v4l-utils \
#         zlib1g-dev

# #build opencv
# RUN adduser --system --group --no-create-home builder && \
#     mkdir ${BUILD_TMP} && cd ${BUILD_TMP} &&\
#     gosu builder git clone --depth 1 --branch 4.5.1 https://github.com/opencv/opencv.git &&\
#     gosu builder git clone --depth 1 --branch 4.5.1 https://github.com/opencv/opencv_contrib.git &&\
#     cd opencv &&\
#     mkdir build && chown builder:builder build &&\
#     cd build &&\
#     gosu builder cmake ${CMAKEFLAGS} .. &&\
#     gosu builder make -j1 &&\
#     make install

# CMD ["bin/bash"]
#______________________________________________________#

# FROM nvcr.io/nvidia/l4t-tensorflow:r32.6.1-tf1.15-py3

# RUN apt-get update || apt-get install -y ca-certificates

# RUN apt-get update && apt-get install -y python3-pip python3-dev git

# RUN pip3 install --no-cache-dir --upgrade pip \
#     && pip3 --no-cache-dir install Jetson.GPIO 

# RUN apt-get install -y unzip cmake \
#     && wget https://github.com/davisking/dlib/archive/refs/tags/v19.22.zip \
#     && unzip v19.22 \
#     && cd dlib-19.22 \
#     && python3 setup.py install --user

# # RUN pip3 uninstall -y h5py && apt-get -y install python3-h5py

# COPY . .

# # RUN pip3 install -U setuptools pip protobuf==3.3.0 \
# #     && pip3 install opencv-contrib-python-headless

# # RUN pip3 install --no-dependencies opencv-python

# RUN apt-get update && apt-get install -y libopencv-dev && apt-get install -y --no-install-recommends \
#     build-essential \
#     zlib1g-dev \
#     zip \
#     libjpeg8-dev && rm -rf /var/lib/apt/lists/*

# RUN pip3 install setuptools Cython wheel
# RUN pip3 install numpy --verbose

# CMD ["/bin/bash"]

########################################
### -- crus012/jetpackbase:latest -- ###

# FROM mdegans/tegra-opencv:latest

# RUN apt-get update || apt-get install -y ca-certificates

# RUN apt-get update && apt-get install -y python3-pip python3-dev

# RUN pip3 install --no-cache-dir --upgrade pip \
#     && pip3 --no-cache-dir install keras Jetson.GPIO \ 
#     && pip install numpy==1.19.4 \
#     && pip install --no-cache-dir tensorflow -f https://tf.kmtea.eu/whl/stable.html

# RUN apt-get install -y unzip cmake \
#     && wget https://github.com/davisking/dlib/archive/refs/tags/v19.22.zip \
#     && unzip v19.22 \
#     && cd dlib-19.22 \
#     && python3 setup.py install --user

# RUN pip3 uninstall -y h5py && apt-get -y install python3-h5py

# RUN apt-get install git -y

# COPY . .


# CMD ["python3","-u","cnn_main.py"]

###########################################
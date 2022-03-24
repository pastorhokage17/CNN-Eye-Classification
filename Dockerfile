FROM mdegans/tegra-opencv:latest

RUN apt-get update || apt-get install -y ca-certificates

RUN apt-get update && apt-get install -y python3-pip python3-dev

#hanap ka keras para sa docker container
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 --no-cache-dir install keras Jetson.GPIO \ 
    && pip install numpy==1.19.4 \
    && pip install --no-cache-dir tensorflow -f https://tf.kmtea.eu/whl/stable.html

RUN apt-get install -y unzip cmake \
    && wget https://github.com/davisking/dlib/archive/refs/tags/v19.22.zip \
    && unzip v19.22 \
    && cd dlib-19.22 \
    && python3 setup.py install --user

COPY . .

RUN pip3 uninstall -y h5py && apt-get -y install python3-h5py

RUN apt-get install git

# CMD [ "/bin/bash" ]

CMD ["python3","cnn_main.py"]


#====================================== 
# FROM nvcr.io/nvidia/l4t-base:r32.4.3

# ENV DEBIAN_FRONTEND = noninteractive

# RUN apt-get update -y && apt-get install -y \
#             build-essential \
#             cmake \
#             git \
#             unzip \
#             pkg-config\
#             libprotobuf-dev \
#             libgoogle-glog-dev \
#             libgflags-dev \
#             libhdf5-dev \
#             protobuf-compiler \
#             liblapack-dev \
#             libeigen3-dev \
#             gfortran \
#             libopenblas-dev \
#             libatlas-base-dev \
#             libblas-dev \
#             libopencore-amrnb-dev \
#             libopencore-amrwb-dev \
#             libfaac-dev \
#             libmp3lame-dev \
#             libtheora-dev \
#             libavresample-dev \
#             libvorbis-dev \
#             libxine2-dev \
#             libgstreamer1.0-dev \
#             libgstreamer-plugins-base1.0-dev \
#             libv4l-dev \
#             v4l-utils \
#             libtbb2 \
#             libtbb-dev \
#             libdc1394-22-dev \
#             libxvidcore-dev \
#             libx264-dev \
#             libgtk-3-dev \
#             python3-dev \
#             python3-numpy \
#             python3-pip \
#             libgtk2.0-dev \
#             libcanberra-gtk* \
#             libavcodec-dev \
#             libavformat-dev \
#             libswscale-dev \
#             libjpeg-dev \
#             libpng-dev \
#             libtiff-dev 

# RUN wget -O opencv-4.5.1.zip https://github.com/opencv/opencv/archive/4.5.1.zip \
#     && wget -O opencv_contrib-4.5.1.zip https://github.com/opencv/opencv_contrib/archive/4.5.1.zip \
#     && unzip opencv-4.5.1.zip \
#     && unzip opencv_contrib-4.5.1.zip \
#     # && mv opencv-4.5.1 opencv \
#     # && mv opencv_contrib-4.5.1 opencv_contrib \
#     # && rm opencv.zip \
#     # && rm opencv_contrib.zip \ 
#     && mkdir opencv-4.5.1/build && cd opencv-4.5.1/build \
#     && cmake -D CMAKE_BUILD_TYPE=RELEASE \
#         -D CMAKE_INSTALL_PREFIX=/usr/local \
#         -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.5.1/modules \
#         -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
#         -D WITH_OPENCL=OFF \
#         -D WITH_CUDA=ON \
#         -D BUILD_opencv_world=OFF \
#         -D WITH_QT=OFF \
#         -D WITH_OPENMP=OFF \
#         -D WITH_OPENGL=OFF \
#         -D BUILD_TIFF=OFF \
#         -D WITH_FFMPEG=ON \
#         -D WITH_GSTREAMER=ON \
#         -D WITH_TBB=ON \
#         -D BUILD_TBB=ON \
#         -D WITH_GTK=ON \
#         -D BUILD_TESTS=OFF \
#         -D WITH_EIGEN=ON \
#         -D WITH_V4L=ON \
#         -D WITH_LIBV4L=ON \
#         -D OPENCV_ENABLE_NONFREE=OFF \
#         -D INSTALL_C_EXAMPLES=OFF \
#         -D INSTALL_PYTHON_EXAMPLES=OFF \
#         -D BUILD_NEW_PYTHON_SUPPORT=ON \
#         -D BUILD_opencv_python3=TRUE \
#         -D BUILD_opencv_python2=FALSE \
#         -D OPENCV_GENERATE_PKGCONFIG=ON \
#         -D BUILD_EXAMPLES=OFF .. \
#     && make -j4 \
#     && make install \
#     && make clean 

# RUN wget https://github.com/davisking/dlib/archive/refs/tags/v19.22.zip \
#     && unzip v19.22 \
#     && cd dlib-19.22 \
#     && python3 setup.py install --user \
#     && cd ..

# RUN pip3 install --no-cache-dir --upgrade pip \
#     && pip3 --no-cache-dir install keras numpy Jetson.GPIO \
#     && pip install --no-cache-dir tensorflow -f https://tf.kmtea.eu/whl/stable.html


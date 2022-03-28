FROM nvcr.io/nvidia/l4t-tensorflow:r32.6.1-tf1.15-py3

RUN apt-get update || apt-get install -y ca-certificates

RUN apt-get update && apt-get install -y python3-pip python3-dev git

RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 --no-cache-dir install Jetson.GPIO 

RUN apt-get install -y unzip cmake \
    && wget https://github.com/davisking/dlib/archive/refs/tags/v19.22.zip \
    && unzip v19.22 \
    && cd dlib-19.22 \
    && python3 setup.py install --user

# RUN pip3 uninstall -y h5py && apt-get -y install python3-h5py

COPY . .

# RUN pip3 install -U setuptools pip protobuf==3.3.0 \
#     && pip3 install opencv-contrib-python-headless

# RUN pip3 install --no-dependencies opencv-python

RUN apt-get install -y libopencv-python \
    && apt-get install -y --no-install-recommends \
    build-essential \
    zlib1g-dev \
    zip \
    libjpeg8-dev && rm -rf /var/lib/apt/lists/*

RUN pip3 install setuptools Cython wheel
RUN pip3 install numpy --verbose

CMD ["/bin/bash"]

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

###########################################
# base image: nvcr.io/nvidia/l4t-tensorflow:r32.6.1-tf1.15-py3
# reference for NVIDIA L4T TensorFlow base images: https://catalog.ngc.nvidia.com/orgs/nvidia/containers/l4t-tensorflow
# intelligent video analytics (deepstream sdk, nvdia stream analytics, azure blob storage) https://github.com/toolboc/Intelligent-Video-Analytics-with-NVIDIA-Jetson-and-Microsoft-Azure
# issue with previous base image
#   1. cant access nvidia-daemon on azure iot hub, for gstreamer pipeline (csi camera)
# imports
# > dlib <--- pwede na kasama sa docker build
# > keras, nag eerror
# > Jetson.GPIO <--- pwede na kasama sa docker build
# > try cv2
# 
# before build, testingin mo muna ung base image
# sudo docker run --runtime nvidia --network host --privileged -v /tmp/argus_socket:/tmp/argus_socket -v /tmp/.X11-unix/:/tmp/.X11-unix  nvcr.io/nvidia/l4t-tensorflow:r32.6.1-tf1.15-py3
#   1. testingin mo ung imports
#   2. git clone --branch ear-cnn-classification https://github.com/pastorhokage17/CNN-Eye-Classification
#   3. python3 cnn_main.py
#   4. lahat to sa loob ng container



# pano tetestingin if ever, yung docker image na bago
#   1. portal.azure.com
#   2. edge-server / edgenode3 / Set modules (bandang taas) / tortang-manok
#   3.  a. palitan mo ng bago ung image URI galing sa bagong binuild mong image (e.g. crus012/nvidiabase:latest)
#       b. Restart Policy: always
#       c. Desired Status: running
#   4. paste mo toh sa container create options
# {
#     "HostConfig": {
#         "Privileged": true,
#         "Volumes": [
#             "/tmp/argus_socket:/tmp/argus_socket",
#             "/tmp/.X11-unix/:/tmp/.X11-unix/"
#         ],
#         "Runtime": "nvidia"
#     }
# }
#   5. update > review + create

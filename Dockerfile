FROM mdegans/tegra-opencv:latest

RUN apt-get update || apt-get install -y ca-certificates

RUN apt-get update && apt-get install -y python3-pip python3-dev

RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 --no-cache-dir install keras Jetson.GPIO \ 
    && pip install numpy==1.19.4 \
    && pip install --no-cache-dir tensorflow -f https://tf.kmtea.eu/whl/stable.html

RUN apt-get install -y unzip cmake \
    && wget https://github.com/davisking/dlib/archive/refs/tags/v19.22.zip \
    && unzip v19.22 \
    && cd dlib-19.22 \
    && python3 setup.py install --user

RUN pip3 uninstall -y h5py && apt-get -y install python3-h5py

RUN apt-get install git -y

COPY . .

CMD ["python3","-u","cnn_main.py"]

########################
# imports
# > dlib
# > keras, nag eerror
# > Jetson.GPIO
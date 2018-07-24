FROM baikangwang/tensorflow_gpu:jupyter
MAINTAINER Baker Wang <baikangwang@hotmail.com>

# referenced from <https://hub.docker.com/r/kevin8093/tf_opencv_contrib/>

RUN apt update && \
    # Dependencies
    apt install -y --no-install-recommends \
    libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libgtk2.0-dev \
    liblapacke-dev checkinstall && \
    apt clean && \
    apt autoremove && \
    rm -rf /var/lib/apt/lists/*
#
# OpenCV 3.3
#
# Get source from github
# git clone https://github.com/opencv/opencv.git /usr/local/src/opencv && \
# git clone https://github.com/opencv/opencv_contrib.git /usr/local/src/opencv_contrib && \
RUN apt update && \
    cd / && \
    wget https://github.com/opencv/opencv/archive/3.3.0.tar.gz -O opencv-3.3.0.tar.gz && \
    tar -xvf opencv-3.3.0.tar.gz && \
    mv opencv-3.3.0 /usr/local/src/opencv && \
    wget https://github.com/opencv/opencv_contrib/archive/3.3.0.tar.gz -O opencv_contrib-3.3.0.tar.gz && \
    tar -xvf opencv_contrib-3.3.0.tar.gz && \
    mv opencv_contrib-3.3.0 /usr/local/src/opencv_contrib && \
    # Compile
    cd /usr/local/src/opencv && mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D BUILD_TESTS=OFF \
          -D BUILD_opencv_gpu=ON \
          -D BUILD_PERF_TESTS=OFF \
          -D WITH_IPP=OFF \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules -D BUILD_opencv_xfeatures2d=OFF /usr/local/src/opencv \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules -D BUILD_opencv_dnn_modern=OFF /usr/local/src/opencv \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules -D BUILD_opencv_dnns_easily_fooled=OFF /usr/local/src/opencv \
          -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) \
          .. && \
    make -j"$(nproc)" && \
    make install && \
    #
    # Cleanup
    #
    rm /opencv-3.3.0.tar.gz && rm /opencv_contrib-3.3.0.tar.gz && \
    cd /usr/local/src/opencv && rm -r build && \
    apt clean && \
    apt autoremove && \
    rm -rf /var/lib/apt/lists/*

    CMD ["/bin/bash"]
FROM ubuntu:16.04
MAINTAINER Baker Wang <baikangwang@hotmail.com>

# referenced from <https://hub.docker.com/r/kevin8093/tf_opencv_contrib/>

# Supress warnings about missing front-end. As recommended at:
# http://stackoverflow.com/questions/22466255/is-it-possibe-to-answer-dialog-questions-when-installing-under-docker
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y --no-install-recommends apt-utils \
    # Developer Essentials
    git curl vim unzip openssh-client wget \
    # Build tools
    build-essential cmake \
    # OpenBLAS
    libopenblas-dev \
    # Pillow and it's dependencies
    libjpeg-dev zlib1g-dev \
    #
    # Python 3.5
    #
    python3.5 python3.5-dev python3-pip && \
    pip3 install --no-cache-dir --upgrade pip setuptools && \
    # For convenience, alisas (but don't sym-link) python & pip to python3 & pip3 as recommended in:
    # http://askubuntu.com/questions/351318/changing-symlink-python-to-python3-causes-problems
    echo "alias python='python3'" >> /root/.bash_aliases && \
    echo "alias pip='pip3'" >> /root/.bash_aliases && \
    pip3 install --no-cache-dir Pillow \
    # Common libraries
    numpy scipy sklearn scikit-image pandas matplotlib \
    #
    # Jupyter Notebook
    #
    jupyter && \
    # Allow access from outside the container, and skip trying to open a browser.
    # NOTE: disable authentication token for convenience. DON'T DO THIS ON A PUBLIC SERVER.
    mkdir /root/.jupyter && \
    echo "c.NotebookApp.ip = '*'" \
         "\nc.NotebookApp.open_browser = False" \
         "\nc.NotebookApp.token = ''" \
         > /root/.jupyter/jupyter_notebook_config.py && \
    # Juypter notebook extensions
    # <https://github.com/ipython-contrib/jupyter_contrib_nbextensions>
    #
    pip3 --no-cache-dir install jupyter_contrib_nbextensions \
    #
    # Prerequisites of the extension Code Prettifier
    yapf && \
    # install javascript and css files
    jupyter contrib nbextension install --user && \
    # enable code prettifier
    jupyter nbextension enable code_prettify/code_prettify && \
    #
    # Tensorflow 1.3.0 - CPU
    #
    pip3 install --no-cache-dir --upgrade tensorflow && \
    #
    # OpenCV 3.2
    #
    # Dependencies
    apt-get install -y --no-install-recommends \
    libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libgtk2.0-dev \
    liblapacke-dev checkinstall && \
    # Get source from github
    #git clone https://github.com/opencv/opencv.git /usr/local/src/opencv && \
    #git clone https://github.com/opencv/opencv_contrib.git /usr/local/src/opencv_contrib && \
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
          -D BUILD_opencv_gpu=OFF \
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
    cd / && rm opencv-3.3.0.tar.gz && rm opencv_contrib-3.3.0.tar.gz && \
    cd /usr/local/src/opencv && rm -r build && \
    apt clean && \
    apt autoremove && \
    rm -rf /var/lib/apt/lists/*
#
# Jupyter Notebook : 8888
# Tensorboard : 6006
#
EXPOSE 8888 6006

COPY run_jupyter.sh /

WORKDIR "/notebooks"
CMD ["/run_jupyter.sh", "--allow-root"]
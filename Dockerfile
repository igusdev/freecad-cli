FROM ubuntu:24.04
ARG freecad_version=1.0.2

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHON_VERSION 3.12.7
ENV PYTHON_MINOR_VERSION 3.12
ENV PYTHON_BIN_VERSION python3.12
ENV FREECAD_REPO https://github.com/FreeCAD/FreeCAD.git

RUN \
    pack_build=" \
    build-essential cmake git \
    gmsh libboost-date-time-dev libboost-dev \
    libboost-filesystem-dev libboost-graph-dev libboost-iostreams-dev \
    libboost-program-options-dev libboost-python-dev libboost-regex-dev \
    libboost-serialization-dev libboost-thread-dev libcoin-dev \
    libeigen3-dev libgts-bin libgts-dev libkdtree++-dev \
    libmedc-dev libmetis-dev libocct-data-exchange-dev \
    libocct-draw-dev libocct-foundation-dev libocct-modeling-algorithms-dev \
    libocct-modeling-data-dev libocct-ocaf-dev libocct-visualization-dev \
    libopencv-dev libproj-dev libqt5svg5-dev\
    libtool libvtk9-dev libvtk-dicom-dev \
    libx11-dev libxerces-c-dev libzipios++-dev \
    libgtkglext1-dev libkml-dev libpyside2-dev \
    libshiboken2-dev libvtk9-qt-dev libxmu-dev libxmuu-dev \
    libyaml-cpp-dev lsb-release netgen \
    netgen-headers occt-draw pipx \
    python$PYTHON_MINOR_VERSION python$PYTHON_MINOR_VERSION-dev python3-setuptools \
    pyside2-tools python3-matplotlib python3-pivy \
    python3-ply python3-pyside2.qtsvg python3-pyside2.qtuitools \
    python3-pyside2.qtcore python3-pyside2.qtgui python3-pyside2.qtwidgets \
    python3-pyside2.qtnetwork python3-pip python3-netgen \
    qtchooser qttools5-dev shiboken2 qtwayland5 \
    qtbase5-dev swig wget \
    " \
    && apt update \
    && apt install -y --no-install-recommends software-properties-common \
    && apt install -y --no-install-recommends $pack_build

RUN pipx ensurepath

ENV PYTHONPATH "/usr/local/lib:$PYTHONPATH"

# get FreeCAD Git
RUN cd && git clone --depth 1 --recurse-submodules --shallow-submodules --branch "$freecad_version" "$FREECAD_REPO"

RUN \
    cd \
    && mkdir freecad-build \
    && cd freecad-build \
    # Build \
    && cmake \
    # Build with GUI for now otherwise qt components are not found
    # in some modules like TechDraw
    # -DBUILD_GUI=OFF \
    # -DBUILD_QT5=OFF \
    -DPYTHON_EXECUTABLE=/usr/bin/$PYTHON_BIN_VERSION \
    -DPYTHON_INCLUDE_DIR=/usr/include/$PYTHON_BIN_VERSION \
    -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/lib${PYTHON_BIN_VERSION}.so \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_FEM_NETGEN=ON \
    -DENABLE_DEVELOPER_TESTS=OFF \
    ../FreeCAD \
    \
    && make -j$(nproc --ignore=2) \
    && make install \
    && cd \
    \
    # Clean
    && rm FreeCAD/ freecad-build/ -fR

# FreeCAD import PySide2 module as `import PySide`
RUN ln -s /usr/lib/python3/dist-packages/PySide2 /usr/lib/python3/dist-packages/PySide

# Fixed import MeshPart module due to missing libnglib.so
# https://bugs.launchpad.net/ubuntu/+source/freecad/+bug/1866914
RUN echo "/usr/lib/x86_64-linux-gnu/netgen" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf
RUN ldconfig

# Make Python already know all FreeCAD modules / workbenches.
ENV FREECAD_STARTUP_FILE /.startup.py
RUN echo "import FreeCAD" > ${FREECAD_STARTUP_FILE}
ENV PYTHONSTARTUP ${FREECAD_STARTUP_FILE}

# Clean
RUN apt-get clean \
    && rm /var/lib/apt/lists/* \
    /usr/share/doc/* \
    /usr/share/locale/* \
    /usr/share/man/* \
    /usr/share/info/* -fR

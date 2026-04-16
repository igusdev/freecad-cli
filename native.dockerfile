FROM ubuntu:24.04
ARG freecad_version=1.1.1

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_MINOR_VERSION=3.12
ENV PYTHON_BIN_VERSION=python3.12
ENV FREECAD_REPO=https://github.com/FreeCAD/FreeCAD.git

RUN \
    apt update \
    && apt-get upgrade --yes \
    && apt-get install -y --no-install-recommends \
        software-properties-common wget gnupg2 ca-certificates \
    && wget -qO- http://archive.neon.kde.org/public.key | gpg --dearmor -o /usr/share/keyrings/neon-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/neon-keyring.gpg] http://archive.neon.kde.org/user noble main" > /etc/apt/sources.list.d/neon-qt.list \
    && apt-get update -qq \
    && apt install -y --no-install-recommends \
        build-essential cmake git ninja-build \
        gmsh libboost-date-time-dev libboost-dev \
        libboost-filesystem-dev libboost-graph-dev libboost-iostreams-dev \
        libboost-program-options-dev libboost-python-dev libboost-regex-dev \
        libboost-serialization-dev libboost-thread-dev libcoin-dev \
        libeigen3-dev libgts-bin libgts-dev libkdtree++-dev \
        libmedc-dev libmetis-dev libocct-data-exchange-dev \
        libocct-draw-dev libocct-foundation-dev libocct-modeling-algorithms-dev \
        libocct-modeling-data-dev libocct-ocaf-dev libocct-visualization-dev \
        libopencv-dev libproj-dev libqt6svg6-dev \
        libtool libvtk9-dev libvtk-dicom-dev \
        libx11-dev libxerces-c-dev libzipios++-dev \
        libgtkglext1-dev libkml-dev libpyside6-dev \
        libqt6opengl6-dev libshiboken6-dev libvtk9-qt-dev \
        libspnav-dev libxmu-dev libxmuu-dev \
        libyaml-cpp-dev lsb-release netgen \
        netgen-headers occt-draw \
        python$PYTHON_MINOR_VERSION-full python$PYTHON_MINOR_VERSION-dev python3-setuptools \
        pyside6-tools python3-matplotlib python3-pivy \
        python3-defusedxml python3-lark python3-markdown \
        python3-ply python3-pybind11 python3-netgen \
        python3-pip python3-pyside6.qtcore python3-pyside6.qtgui \
        python3-pyside6.qtnetwork python3-pyside6.qtsvg python3-pyside6.qtwidgets \
        qt6-base-dev qt6-tools-dev qt6-tools-dev-tools \
        qt6-wayland swig xvfb \
    && apt-get clean \
    && rm /var/lib/apt/lists/* \
    /usr/share/doc/* \
    /usr/share/locale/* \
    /usr/share/man/* \
    /usr/share/info/* -fR

ENV PYTHONPATH="/usr/local/lib"

RUN \
    cd \
    && git clone --depth 1 --recurse-submodules --shallow-submodules --branch "$freecad_version" "$FREECAD_REPO" \
    && mkdir freecad-build \
    && cd freecad-build \
    # Build \
    && cmake -G Ninja \
    -DPYTHON_EXECUTABLE=/usr/bin/$PYTHON_BIN_VERSION \
    -DPYTHON_INCLUDE_DIR=/usr/include/$PYTHON_BIN_VERSION \
    -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/lib${PYTHON_BIN_VERSION}.so \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_FEM_NETGEN=ON \
    -DFREECAD_QT_VERSION:STRING=6 \
    -DENABLE_DEVELOPER_TESTS=OFF \
    ../FreeCAD \
    \
    && ninja \
    && ninja install \
    && cd \
    \
    # Clean
    && rm FreeCAD/ freecad-build/ -fR

# FreeCAD import PySide6 module as `import PySide`
RUN ln -s /usr/lib/python3/dist-packages/PySide6 /usr/lib/python3/dist-packages/PySide

# Fixed import MeshPart module due to missing libnglib.so
# https://bugs.launchpad.net/ubuntu/+source/freecad/+bug/1866914
RUN echo "/usr/lib/x86_64-linux-gnu/netgen" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf
RUN ldconfig

# Make Python already know all FreeCAD modules / workbenches.
ENV FREECAD_STARTUP_FILE=/.startup.py
RUN echo "import FreeCAD" > ${FREECAD_STARTUP_FILE}
ENV PYTHONSTARTUP=${FREECAD_STARTUP_FILE}

# Make sure xvfb-run does not redirect stderr to stdout
RUN sed -i 's|DISPLAY=:\$SERVERNUM XAUTHORITY=\$AUTHFILE "$@" 2>&1|DISPLAY=:\$SERVERNUM XAUTHORITY=\$AUTHFILE "$@"|g' /usr/bin/xvfb-run

# Ensure XDG_RUNTIME_DIR is set and has the correct permissions
ENV XDG_RUNTIME_DIR=/tmp/runtime-freecad
RUN mkdir -p ${XDG_RUNTIME_DIR} && chmod 700 ${XDG_RUNTIME_DIR}

FROM ubuntu:24.04
ARG freecad_version=1.1rc2
ARG python_version=311
ARG TARGETPLATFORM

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    curl xvfb \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN case "$TARGETPLATFORM" in \
    *"amd64"*) FC_ARCH="x86_64" ;; \
    *"arm64"*) FC_ARCH="aarch64" ;; \
    esac; \
    curl -L https://github.com/FreeCAD/FreeCAD/releases/download/${freecad_version}/FreeCAD_${freecad_version}-Linux-${FC_ARCH}-py${python_version}.AppImage > FreeCAD.AppImage && \
    chmod +x ./FreeCAD.AppImage && \
    ./FreeCAD.AppImage --appimage-extract && \
    rm FreeCAD.AppImage && \
    ln -s /squashfs-root/AppRun /usr/local/bin/freecad

# Make sure xvfb-run does not redirect stderr to stdout
RUN sed -i 's|-DISPLAY=:\$SERVERNUM XAUTHORITY=\$AUTHFILE "$@" 2>&1|-DISPLAY=:\$SERVERNUM XAUTHORITY=\$AUTHFILE "$@"|g' /usr/bin/xvfb-run

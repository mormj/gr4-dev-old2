FROM fedora:44

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PKG_CONFIG=pkg-config

# Shared prerequisites for Fedora 44 builder profiles.
RUN dnf -y update \
    && dnf -y install \
       bash \
       ccache \
       ca-certificates \
       cmake \
       file \
       findutils \
       gcc \
       gcc-c++ \
       git \
       gpg \
       lsb-release \
       make \
       ninja-build \
       pkgconf-pkg-config \
       python3 \
       python3-devel \
       python3-numpy \
       pybind11-devel \
       wget \
    && dnf clean all

RUN dnf -y install \
    cppzmq-devel \
    boost-devel \
    brotli-devel \
    libcurl-devel \
    cpp-httplib-devel \
    fftw-devel \
    gtest-devel \
    openssl-devel \
    tbb-devel \
    json-devel \
    cli11-devel \
    rtaudio-devel \
    portaudio-devel \
    SoapySDR-devel \
    && dnf clean all

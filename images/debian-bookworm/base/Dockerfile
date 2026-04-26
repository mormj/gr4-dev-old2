FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PKG_CONFIG=pkg-config

# Shared prerequisites for Debian bookworm builder profiles.
RUN apt-get update -q && apt-get install --no-install-recommends -qy \
    bash \
    build-essential \
    ca-certificates \
    ccache \
    cmake \
    file \
    git \
    gpg \
    lsb-release \
    locales \
    make \
    ninja-build \
    pkg-config \
    software-properties-common \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update -q && apt-get install --no-install-recommends -qy \
    cppzmq-dev \
    libboost-system-dev \
    libbrotli-dev \
    libcurl4-openssl-dev \
    libcpp-httplib-dev \
    libfftw3-dev \
    libgtest-dev \
    libssl-dev \
    libtbb-dev \
    nlohmann-json3-dev \
    python3 \
    python3-dev \
    python3-numpy \
    pybind11-dev \
    libcli11-dev \
    librtaudio-dev \
    libportaudio2 \
    libsoapysdr-dev \
    soapysdr-module-hackrf \
    soapysdr-tools \
    && rm -rf /var/lib/apt/lists/*

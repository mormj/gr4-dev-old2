ARG BASE_IMAGE=gr4-ci/debian-sid-base:latest
FROM ${BASE_IMAGE}

# Toolchain profile for Debian sid using the distro-default GCC toolchain.
RUN apt-get update -q && apt-get install --no-install-recommends -qy \
    gcc \
    g++ \
    libstdc++-15-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CC=gcc \
    CXX=g++

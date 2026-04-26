ARG BASE_IMAGE=gr4-ci/ubuntu-26.04-base:latest
FROM ${BASE_IMAGE}

# Toolchain profile for Ubuntu 26.04 using the distro-default GCC toolchain.
RUN apt-get update -q && apt-get install --no-install-recommends -qy \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

ENV CC=gcc \
    CXX=g++

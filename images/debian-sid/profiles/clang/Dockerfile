ARG BASE_IMAGE=gr4-ci/debian-sid-base:latest
FROM ${BASE_IMAGE}

# Toolchain profile for Debian sid using the distro-default clang and libc++ stack.
RUN apt-get update -q && apt-get install --no-install-recommends -qy \
    clang \
    libc++-dev \
    libc++abi-dev \
    libunwind-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 120

ENV CC=clang \
    CXX=clang++

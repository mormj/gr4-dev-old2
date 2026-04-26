ARG BASE_IMAGE=gr4-ci/ubuntu-26.04-base:latest
FROM ${BASE_IMAGE}

# Toolchain profile for Ubuntu 26.04 using the distro-default clang and libc++ stack.
RUN apt-get update -q && apt-get install --no-install-recommends -qy \
    clang \
    libc++-dev \
    libc++abi-dev \
    libunwind-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 120

ENV CC=clang \
    CXX=clang++

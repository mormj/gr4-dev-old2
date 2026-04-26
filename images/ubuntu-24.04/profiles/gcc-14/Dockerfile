ARG BASE_IMAGE=gr4-ci/ubuntu-24.04-base:latest
FROM ${BASE_IMAGE}

# Toolchain profile for Ubuntu 24.04 with GCC 14 from the distro packages.
RUN apt-get update -q && apt-get install --no-install-recommends -qy \
    gcc-14 \
    g++-14 \
    libstdc++-14-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 140 \
      --slave /usr/bin/g++ g++ /usr/bin/g++-14 \
      --slave /usr/bin/gcov gcov /usr/bin/gcov-14 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-14 140

ENV CC=gcc-14 \
    CXX=g++-14

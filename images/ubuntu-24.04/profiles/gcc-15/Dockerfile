ARG BASE_IMAGE=gr4-ci/ubuntu-24.04-base:latest
FROM ${BASE_IMAGE}

# Toolchain profile for Ubuntu 24.04 with GCC 15 from ubuntu-toolchain-r/test.
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test

RUN apt-get update -q && apt-get install --no-install-recommends -qy \
    gcc-15 \
    g++-15 \
    libstdc++-15-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-15 150 \
      --slave /usr/bin/g++ g++ /usr/bin/g++-15 \
      --slave /usr/bin/gcov gcov /usr/bin/gcov-15 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-15 150

ENV CC=gcc-15 \
    CXX=g++-15

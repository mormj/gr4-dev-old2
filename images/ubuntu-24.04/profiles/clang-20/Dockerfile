ARG BASE_IMAGE=gr4-ci/ubuntu-24.04-base:latest
FROM ${BASE_IMAGE}

# Toolchain profile for Ubuntu 24.04 with clang-20 and matching GCC packages.
RUN install -d -m 0755 /etc/apt/keyrings \
    && wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /etc/apt/keyrings/llvm.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/llvm.gpg] https://apt.llvm.org/noble/ llvm-toolchain-noble-20 main" \
       > /etc/apt/sources.list.d/llvm20.list

RUN apt-get update -q && apt-get install --no-install-recommends -qy \
    gcc-14 \
    g++-14 \
    clang-20 \
    libc++-20-dev \
    libc++abi-20-dev \
    libunwind-20-dev \
    libstdc++-14-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 140 \
      --slave /usr/bin/g++ g++ /usr/bin/g++-14 \
      --slave /usr/bin/gcov gcov /usr/bin/gcov-14 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-20 120

ENV CC=clang-20 \
    CXX=clang++-20

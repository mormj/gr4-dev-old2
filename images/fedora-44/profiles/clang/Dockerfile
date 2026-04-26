ARG BASE_IMAGE=gr4-ci/fedora-44-base:latest
FROM ${BASE_IMAGE}

# Toolchain profile for Fedora 44 using the distro-default Clang toolchain.
RUN dnf -y install \
    clang \
    libcxx-devel \
    libcxxabi-devel \
    libunwind-devel \
    && dnf clean all

ENV CC=clang \
    CXX=clang++


FROM ubuntu:14.04

# Inspired by klee's docker file

# FIXME: Docker doesn't currently offer a way to
# squash the layers from within a Dockerfile so
# the resulting image is unnecessarily large!

ENV LLVM_VERSION=3.6

# TODO: This command is currently borrowed from klee's
# Dockerfile, it seems to provide all the necessary that
# we need in order to build coreutils.
RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        clang-${LLVM_VERSION} \
        llvm-${LLVM_VERSION} \
        llvm-${LLVM_VERSION}-dev \
        llvm-${LLVM_VERSION}-runtime \
        llvm \
        libcap-dev \
        git \
        subversion \
        cmake \
        make \
        libboost-program-options-dev \
        python3 \
        python3-dev \
        python3-pip \
        perl \
        flex \
        bison \
        libncurses-dev \
        zlib1g-dev \
        patch \
        wget \
        unzip \
        libedit-dev \
        binutils && \
    pip3 install -U lit tabulate && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 50

# Extra dependencies needed by coreutils
RUN apt-get -y --no-install-recommends install \
    autoconf \
    automake \
    autopoint \
    gettext \
    gperf \
    texinfo \
    rsync \
    xz-utils

# Create ``llvm-coreutils`` user for container with password ``llvm-coreutils``.
# and give it password-less sudo access (temporarily so we can use the TravisCI scripts)
RUN useradd -m llvm-coreutils && \
    echo llvm-coreutils:llvm-coreutils | chpasswd && \
    cp /etc/sudoers /etc/sudoers.bak && \
    echo 'llvm-coreutils  ALL=(root) NOPASSWD: ALL' >> /etc/sudoers
USER llvm-coreutils
WORKDIR /home/llvm-coreutils

RUN git clone git://git.sv.gnu.org/coreutils
WORKDIR /home/llvm-coreutils/coreutils

# I remember it was merely impossible to build a newer version of coreutils in Ubuntu 14.04
RUN git checkout v8.21

RUN export CC=clang-3.6 && \
    export CXX=clang++-3.6 && \
    export RANLIB=llvm-ranlib-3.6 && \
    export AR=llvm-ar-3.6 && \
    export CFLAGS=" -flto -std=gnu99 " && \
    export LDFLAGS=" -flto -fuse-ld=gold  -Wl,-plugin-opt=save-temps " && \
    ./bootstrap && \
    ./configure && \
    make

# Revoke password-less sudo and Set up sudo access for the ``klee`` user so it
# requires a password
USER root
RUN mv /etc/sudoers.bak /etc/sudoers && \
    echo 'llvm-coreutils  ALL=(root) ALL' >> /etc/sudoers
USER llvm-coreutils

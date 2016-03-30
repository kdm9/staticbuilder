FROM centos:5
MAINTAINER Kevin Murray <spam@kdmurray.id.au>


RUN yum update -y                           && \
    yum groupinstall -y "Development Tools" && \
    yum install -y wget less epel-release   && \
    yum install -y vim-enhanced git

WORKDIR /tmp
RUN wget https://mirrors.kernel.org/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2 \
    && wget http://zlib.net/zlib-1.2.8.tar.xz \
    && wget http://cmake.org/files/v3.4/cmake-3.4.1.tar.gz \
    && wget http://downloads.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.bz2 \
    && wget http://tukaani.org/xz/xz-5.2.2.tar.xz \
    && wget http://bzip.org/1.0.6/bzip2-1.0.6.tar.gz \

WORKDIR /usr/local/src

ENV CC=/usr/bin/gcc CXX=/usr/bin/gcc

# Obtain GCC sources (and dependencies)
RUN tar xvf /tmp/gcc-*.tar*                 && \
    cd /usr/local/src/gcc*                  && \
    ./contrib/download_prerequisites        && \
    ./configure --enable-languages=c,c++,fortran --disable-multilib && \
    make -j4                                && \
    make install                            && \
    cd /usr/local/src                       && \
    rm -rf /usr/local/src/* /tmp/gcc-*

# Zlib
RUN tar xvf /tmp/zlib*.tar*                 && \
    cd /usr/local/src/zlib*                 && \
    ./configure                             && \
    make -j4                                && \
    make check                              && \
    make install                            && \
    cd /usr/local/src                       && \
    rm -rf /usr/local/src/* /tmp/zlib*

# Bzip2
RUN tar xvf /tmp/bzip2-*.tar*               && \
    cd /usr/local/src/bzip2-*               && \
    make -f Makefile CFLAGS=-fPIC all install clean && \
    make -f Makefile-libbz2_so all          && \
    mv libbz2.so* /usr/local/lib/           && \
    cd /usr/local/src                       && \
    rm -f /usr/local/src/* /tmp/bzip2-*


# xz
RUN tar xvf /tmp/xz-*.tar*                  && \
    cd /usr/local/src/xz-*                  && \
    ./configure                             && \
    make -j4                                && \
    make check                              && \
    make install                            && \
    cd /usr/local/src                       && \
    rm -rf /usr/local/src/* /tmp/xz-*


# CMake
RUN tar xvf /tmp/cmake-*.tar*               && \
    cd /usr/local/src/cmake-*               && \
    ./configure                             && \
    make -j4                                && \
    make install                            && \
    cd /usr/local/src                       && \
    rm -rf /usr/local/src* /tmp/cmake-*


# Boost
RUN tar xvf /tmp/boost_*.tar                && \
    cd /usr/local/src/boost_*               && \
    ./bootstrap.sh                          && \
    ./b2 --without-python install           && \
    cd /usr/local/src                       && \
    rm -rf /usr/local/src/* /tmp/boost_*


# Clean up ENV
RUN unset CC CXX
WORKDIR /root

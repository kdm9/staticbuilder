FROM debian:squeeze
MAINTAINER Kevin Murray <spam@kdmurray.id.au>

ENV gccver 5.3.0
ENV zlibver 1.2.8
ENV bz2ver 1.0.6
ENV xzver 5.2.2

# Update debian & install generic dependencies
RUN sed -i -e 's/httpredir.debian.org/mirrors.kernel.org/' \
        /etc/apt/sources.list               && \
    apt-get update                          && \
    apt-get upgrade -yy                     && \
    apt-get install -yy \
        build-essential \
        vim \
        git \
        gcc-multilib \
        wget \
        less                                && \
    apt-get clean -yy                       && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*


# Obtain GCC sources (and dependencies)
ADD http://mirrors.kernel.org/gnu/gcc/gcc-${gccver}/gcc-${gccver}.tar.bz2 /tmp/
WORKDIR /usr/local/src
RUN tar xvf /tmp/gcc-${gccver}.tar.bz2      && \
    cd /usr/local/src/gcc-${gccver}         && \
    ./contrib/download_prerequisites        && \
    ./configure --enable-languages=c,c++,fortran && \
    make -j4                                && \
    make install                            && \
    cd /usr/local/src                       && \
    rm -f /tmp/gcc-${gccver}.tar.bz2        && \
    rm -rf /usr/local/src/gcc-${gccver}

# Set library paths appropriately for new GCC
#RUN echo '/usr/local/lib64' > /etc/ld.so.conf.d/gcc.conf
#RUN echo '/usr/local/lib32' >> /etc/ld.so.conf.d/gcc.conf
#RUN update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/gcc 100 \
#        --slave /usr/bin/g++ g++ /usr/local/bin/g++
#RUN ldconfig

# Zlib
ADD http://zlib.net/zlib-${zlibver}.tar.xz /tmp/
RUN tar xvf /tmp/zlib-${zlibver}.tar.xz     && \
    cd /usr/local/src/zlib-${zlibver}       && \
    CC=/usr/bin/gcc                         && \
    ./configure                             && \
    make -j4                                && \
    make check                              && \
    make install                            && \
    rm -f /tmp/zlib-${zlibver}.tar.xz       && \
    cd /usr/local/src                       && \
    rm -rf /usr/local/src/zlib-${zlibver}

# Bzip2
ADD http://bzip.org/${bz2ver}/bzip2-${bz2ver}.tar.gz /tmp/
RUN tar xvf /tmp/bzip2-${bz2ver}.tar.gz     && \
    cd /usr/local/src/bzip2-${bz2ver}       && \
    export CC=/usr/bin/gcc                  && \
    make -f Makefile CFLAGS=-fPIC all install clean && \
    make -f Makefile-libbz2_so all          && \
    mv libbz2.so* /usr/local/lib/           && \
    cd /usr/local/src                       && \
    rm -f /tmp/bzip2-${bz2ver}.tar.gz       && \
    rm -rf /usr/local/src/bzip2-${bz2ver}


# xz
ADD http://tukaani.org/xz/xz-${xzver}.tar.xz /tmp/
RUN tar xvf /tmp/xz-${xzver}.tar.xz         && \
    cd /usr/local/src/xz-${xzver}           && \
    export CC=/usr/bin/gcc                  && \
    ./configure                             && \
    make -j4                                && \
    make check                              && \
    make install                            && \
    cd /usr/local/src                       && \
    rm -f /tmp/xz-${xzver}.tar.xz           && \
    rm -rf /usr/local/src/xz-${xzver}


# CMake
ADD https://cmake.org/files/v3.4/cmake-3.4.1.tar.gz /tmp/
RUN tar xvf /tmp/cmake-3.4.1.tar.gz         && \
    cd /usr/local/src/cmake-3.4.1           && \
    export CC=/usr/bin/gcc                  && \
    export CXX=/usr/bin/g++                 && \
    ./configure                             && \
    make -j4                                && \
    make install                            && \
    cd /usr/local/src                       && \
    rm -f /tmp/cmake-3.4.1.tar.gz           && \
    rm -rf /usr/local/src/cmake-3.4.1


# Boost
ADD http://downloads.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.bz2 /tmp/
RUN tar xvf /tmp/boost_1_60_0.tar.bz2       && \
    cd /usr/local/src/boost_1_60_0          && \
    ./bootstrap.sh                          && \
    ./b2 --without-python install           && \
    cd /usr/local/src                       && \
    rm -f /tmp/boost_1_60_0.tar.bz2         && \
    rm -rf /usr/local/src/boost_1_60_0


# Clean up ENV
RUN unset gccver zlibver bz2ver xzver CC CXX

WORKDIR /root

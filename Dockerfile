FROM debian:squeeze
MAINTAINER Kevin Murray <spam@kdmurray.id.au>

ENV gccver 5.3.0
ENV zlibver 1.2.8
ENV bz2ver 1.0.6
ENV xzver 5.2.2

# Update debian & install generic dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i -e 's/httpredir.debian.org/mirrors.kernel.org/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
    build-essential \
    vim \
    git \
    gcc-multilib \
    wget \
    less


RUN apt-get clean -y
ENV DEBIAN_FRONTEND newt


# Obtain GCC sources (and dependencies)
ADD http://mirrors.kernel.org/gnu/gcc/gcc-${gccver}/gcc-${gccver}.tar.bz2 /tmp/
WORKDIR /usr/local/src
RUN tar xvf /tmp/gcc-${gccver}.tar.bz2
WORKDIR /usr/local/src/gcc-${gccver}
RUN ./contrib/download_prerequisites

# Build & Install GCC
RUN ./configure --enable-languages=c,c++,fortran
RUN make -j4
RUN make install

RUN rm -f /tmp/gcc-${gccver}.tar.bz2

WORKDIR /usr/local/src
RUN rm -rf /usr/local/src/gcc-${gccver}

# Set library paths appropriately for new GCC
RUN echo '/usr/local/lib64' > /etc/ld.so.conf.d/gcc.conf
RUN echo '/usr/local/lib32' >> /etc/ld.so.conf.d/gcc.conf
RUN update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/gcc 100 \
        --slave /usr/bin/g++ g++ /usr/local/bin/g++
RUN ldconfig

# Zlib
ADD http://zlib.net/zlib-${zlibver}.tar.xz /tmp/
RUN tar xvf /tmp/zlib-${zlibver}.tar.xz

WORKDIR /usr/local/src/zlib-${zlibver}
RUN ./configure
RUN make -j4
RUN make check
RUN make install

RUN rm -f /tmp/zlib-${zlibver}.tar.xz

WORKDIR /usr/local/src
RUN rm -rf /usr/local/src/zlib-${zlibver}


# Bzip2
ADD http://bzip.org/${bz2ver}/bzip2-${bz2ver}.tar.gz /tmp/
RUN tar xvf /tmp/bzip2-${bz2ver}.tar.gz

WORKDIR /usr/local/src/bzip2-${bz2ver}
RUN make -f Makefile CFLAGS=-fPIC all install clean
RUN make -f Makefile-libbz2_so all
RUN mv libbz2.so* /usr/local/lib/

RUN rm -f /tmp/bzip2-${bz2ver}.tar.gz

WORKDIR /usr/local/src
RUN rm -rf /usr/local/src/bzip2-${bz2ver}


# xz
ADD http://tukaani.org/xz/xz-${xzver}.tar.xz /tmp/
RUN tar xvf /tmp/xz-${xzver}.tar.xz

WORKDIR /usr/local/src/xz-${xzver}
RUN ./configure
RUN make -j4
RUN make check
RUN make install

RUN rm -f /tmp/xz-${xzver}.tar.xz

WORKDIR /usr/local/src
RUN rm -rf /usr/local/src/xz-${xzver}


# CMake
ADD https://cmake.org/files/v3.4/cmake-3.4.1.tar.gz /tmp/
RUN tar xvf /tmp/cmake-3.4.1.tar.gz

WORKDIR /usr/local/src/cmake-3.4.1
RUN ./configure
RUN make -j4
RUN make install

RUN rm -f /tmp/cmake-3.4.1.tar.gz

WORKDIR /usr/local/src
RUN rm -rf /usr/local/src/cmake-3.4.1


# Boost
ADD http://downloads.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.bz2 /tmp/
RUN tar xvf /tmp/boost_1_60_0.tar.bz2

WORKDIR /usr/local/src/boost_1_60_0
RUN ./bootstrap.sh
RUN ./b2 --without-python install

RUN rm -f /tmp/boost_1_60_0.tar.bz2

WORKDIR /usr/local/src
RUN rm -rf /usr/local/src/boost_1_60_0


# Clean up ENV
RUN unset gccver zlibver bz2ver xzver

WORKDIR /root

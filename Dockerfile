FROM debian:squeeze
MAINTAINER Kevin Murray <spam@kdmurray.id.au>

ENV gccver 5.3.0
ENV zlibver 1.2.8
ENV bz2ver 1.0.6
ENV xzver 5.2.2

# Update debian & install generic dependencies
ENV DEBIAN_FRONTEND noninteractive
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

RUN update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/gcc 100 \
        --slave /usr/bin/g++ g++ /usr/local/bin/g++

RUN rm -f /tmp/gcc-${gccver}.tar.bz2

WORKDIR /usr/local/src
# RUN rm -rf /usr/local/src/gcc-${gccver}


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
# RUN rm -rf /usr/local/src/zlib-${zlibver}


# Bzip2
ADD http://bzip.org/${bz2ver}/bzip2-${bz2ver}.tar.gz /tmp/
RUN tar xvf /tmp/bzip2-${bz2ver}.tar.gz

WORKDIR /usr/local/src/bzip2-${bz2ver}
RUN make -f Makefile all install clean
RUN make -f Makefile-libbz2_so all
RUN mv libbz2.so* /usr/local/lib/

RUN rm -f /tmp/bzip2-${bz2ver}.tar.gz

WORKDIR /usr/local/src
# RUN rm -rf /usr/local/src/bzip2-${bz2ver}


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
# RUN rm -rf /usr/local/src/xz-${xzver

# Clean up ENV
RUN unset gccver zlibver bz2ver xzver

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
RUN make check
RUN make install

RUN update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/gcc-5 100 \
        --slave /usr/bin/g++ g++ /usr/local/bin/g++-5

# Zlib
ADD 
RUN unset gccver zlibver bz2ver xzver

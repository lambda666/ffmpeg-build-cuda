#!/bin/sh

BASEPATH=$(cd `dirname $0`; pwd)

sudo apt install bzip2 -y
sudo apt install wget -y

# nasm ^2.10
# https://www.nasm.us/pub/nasm/releasebuilds/2.15.02/nasm-2.15.02.tar.gz

if [ ! -f /usr/local/bin/nasm ]; then

    if [ ! -f nasm-2.15.02.tar.gz ]; then
        if [ -f third_party/nasm-2.15.02.tar.gz ]; then
            cp third_party/nasm-2.15.02.tar.gz .
        else
            wget https://www.nasm.us/pub/nasm/releasebuilds/2.15.02/nasm-2.15.02.tar.gz
        fi
    fi

    if [ ! -d nasm-2.15.02 ]; then  
        tar -zxf nasm-2.15.02.tar.gz
    fi

    cd nasm-2.15.02
    ./configure
    make -j 4
    make install
    cd $BASEPATH
fi

# cmake ^3.10
if [ ! -f /usr/local/bin/cmake ]; then
    if [ ! -f v3.15.5.tar.gz ]; then
        if [ -f third_party/v3.15.5.tar.gz ]; then
            cp third_party/v3.15.5.tar.gz .
        else
            wget https://github.com/Kitware/CMake/archive/v3.15.5.tar.gz
        fi
    fi

    tar -zxf v3.15.5.tar.gz
    cd CMake-3.15.5
    ./configure
    make -j 4
    make install
fi

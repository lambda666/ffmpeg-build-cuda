#!/bin/sh

BASEPATH=$(cd `dirname $0`; pwd)
INSTALL_PREFIX=/usr/local
echo $BASEPATH

if [ ! -f $INSTALL_PREFIX/lib/libx264.so ]; then
    tar -jxf third_party/x264-master.tar.bz2
    cd x264-master
    ./configure --prefix=$INSTALL_PREFIX --enable-shared
    make -j 4
    sudo make install
    cd $BASEPATH
fi

if [ ! -f $INSTALL_PREFIX/lib/libx265.so ]; then
    tar -zxf third_party/x265-3.4.tar.gz
    cd x265-3.4
    mkdir gcc
    cd gcc
    cmake $BASEPATH/x265-3.4/source -DENABLE_PIC=ON -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
    make -j 4
    sudo make install 
    cd $BASEPATH

fi

#if [ ! -f $INSTALL_PREFIX/lib/libfreetype.so ]; then
#    tar -zxf third_party/freetype-2.7.tar.gz
#    cd freetype-2.7
#    ./configure --prefix=$INSTALL_PREFIX
#    make -j 4
#    make install
#    cd $BASEPATH
#fi

if [ ! -f $INSTALL_PREFIX/lib64/libexpat.so ]; then
    tar -zxf third_party/libexpat-R_2_2_9.tar.gz
    cd libexpat-R_2_2_9
    mkdir -p gcc
    cmake $BASEPATH/libexpat-R_2_2_9/expat -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
    make -j 4
    sudo make install
    cd $BASEPATH
fi

#if [ ! -f $INSTALL_PREFIX/lib/libfontconfig.so ]; then
#    export FREETYPE_CFLAGS="-I$INSTALL_PREFIX/include/freetype2"
#    export FREETYPE_LIBS="-L$INSTALL_PREFIX/lib -lfreetype"

#    tar -zxf third_party/fontconfig-2.12.0.tar.gz
#    cd fontconfig-2.12.0/
#    ./configure --with-expat-includes=$INSTALL_PREFIX/include/ --with-expat-lib=$INSTALL_PREFIX/lib64
#    make -j 4
#    make install
#    cd $BASEPATH
#fi

echo "build ffmpeg ..."

tar -zxf third_party/ffmpeg-4.0.tar.gz

ADDI_CFLAGS1="-I$INSTALL_PREFIX/include"
ADDI_CFLAGS2="-I/usr/local/cuda/include"
ADDI_LDFLAGS1="-L$INSTALL_PREFIX/lib"
ADDI_LDFLAGS2="-L/usr/local/cuda/lib64"
export PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig

PREFIX=$INSTALL_PREFIX

DIR_FFMPEG=$BASEPATH/ffmpeg-4.0

cp $BASEPATH/patch/libavfilter.v $DIR_FFMPEG/libavfilter/
cp $BASEPATH/patch/mpegts.c $DIR_FFMPEG/libavformat/
cp $BASEPATH/patch/mpegtsenc.c $DIR_FFMPEG/libavformat/
cp $BASEPATH/patch/configure $DIR_FFMPEG/

git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
cd nv-codec-headers # && git checkout n8.1.24.9 && make install
make PREFIX=$INSTALL_PREFIX BINDDIR=$INSTALL_PREFIX
sudo make install PREFIX=$INSTALL_PREFIX BINDDIR=$INSTALL_PREFIX
cd ../

cd ffmpeg-4.0

#--arch=x86_64 
# --disable-asm

./configure --prefix=$PREFIX \
--enable-small --enable-shared --disable-static --disable-debug \
--disable-symver \
--extra-ldflags="-static-libgcc" \
--extra-cflags=$ADDI_CFLAGS1 \
--extra-cflags=$ADDI_CFLAGS2 \
--extra-ldflags=$ADDI_LDFLAGS1 \
--extra-ldflags=$ADDI_LDFLAGS2 \
--pkg-config-flags="--static" \
--extra-libs=-lpthread \
--extra-libs=-lm \
--disable-iconv \
--disable-zlib \
--disable-bzlib \
--disable-x86asm \
--enable-gpl \
--enable-version3 \
--enable-nonfree \
--enable-libx264 \
--enable-encoder=libx264 \
--enable-libx265 \
--enable-encoder=libx265 \
--enable-cuda \
--enable-cuvid \
--enable-nvenc \
--enable-libnpp
#--enable-libopenh264 \
#--enable-encoder=libopenh264
#--enable-libfreetype \
#--enable-fontconfig 

make -j
sudo make install

cd $BASEPATH

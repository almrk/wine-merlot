#!/bin/bash

# Ensure that this is being run from the project root
if [ "$(basename $(pwd))" != "wine-merlot" ]; then
    echo "Please run this script in the project root"
    exit 1
fi

# Folder path variables
CURR_DIR=$(pwd)
BUILD_DIR=$CURR_DIR/build
INST_DIR=$CURR_DIR/install

# Compiler and linker variables
export CC="gcc"
export CXX="g++"
export CFLAGS="-O3 -march=native -mtune=native -funroll-loops -fomit-frame-pointer \
  -fno-stack-protector -fno-plt -fdata-sections -ffunction-sections"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=lld -Wl,-O2 -Wl,--gc-sections -Wl,--icf=all \
  -Wl,-z,now -Wl,-z,relro -Wl,--hash-style=gnu"
export i386_CC="i686-w64-mingw32-gcc"
export i386_CXX="i686-w64-mingw32-g++"
export i386_CFLAGS="-O2 -fno-strict-aliasing"
export i386_CXXFLAGS="-O2 -fno-strict-aliasing"

# Don't bother rebuilding the whole thing if a build already exists
if [ -d "$BUILD_DIR"  ] && [ -n "$(ls -A $BUILD_DIR)" ]; then
    cd $BUILD_DIR
else
    # Setup the build folder
    mkdir $BUILD_DIR
    cd $BUILD_DIR

    # Configure build files
    ../configure \
        --enable-win64 \
        --enable-archs=i386,x86_64 \
        --prefix=$INST_DIR \
        --libdir=$INST_DIR/lib \
        --with-vulkan \
        --with-opengl \
        --with-gstreamer \
        --with-pulse \
        --with-alsa \
        --with-opencl \
        --without-gssapi

    # Build preloader with minimal flags as it is highly sensitive
    make loader/preloader.o CFLAGS="-O2" LDFLAGS=""
    make loader/wine-preloader CFLAGS="-O2" LDFLAGS=""
fi

# Build Wine
make -j$(expr $(nproc) - 2)

# Create an install folder if there isn't one
if [ ! -d "$INST_DIR" ]; then mkdir $INST_DIR; fi

# Install to install folder
make install

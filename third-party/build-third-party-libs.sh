#!/bin/sh

# Copyright © 2022 Roel Janssen <roel@roelj.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

CROSS_GCC=$(find /opt/analog/cces-linux-add-in -name "arm-linux-gnueabi-gcc")
CROSS_ROOT=${CROSS_GCC::-26} # CROSS_GCC without "/bin/arm-linux-gnueabi-gcc"
BASE_DIR="$(pwd)"

## LIBCURL
# -----------------------------------------------------------------------------
# Build without SSL, we will use the library installed on the Quad Cortex
# instead of this one.  However, we need to have the header files and link
# to the library at compile-time.

curl -LO https://curl.se/download/curl-7.86.0.tar.gz
tar axvf curl-7.86.0.tar.gz
cd curl-7.86.0
./configure CC=${CROSS_GCC} --host=armv7 --prefix=$(pwd)/build-output --without-ssl
make
make install
cd ..

## LIBMICROHTTPD
# -----------------------------------------------------------------------------
# Build without eventfd because it seems the kernel on the Quad Cortex doesn't
# support/implement these functions.

curl -LO https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.75.tar.gz
tar axvf libmicrohttpd-0.9.75.tar.gz
cd libmicrohttpd-0.9.75
./configure CC=${CROSS_GCC} --host=armv7 --prefix=$(pwd)/build-output --enable-itc=pipe
make
make install
cd ..

## PROTOBUF-C
# -----------------------------------------------------------------------------
# Disable the dependency on protobuf.  We can pre-generate and include the C/H
# files for the protobuf structures we need.

curl -LO https://github.com/protobuf-c/protobuf-c/releases/download/v1.4.1/protobuf-c-1.4.1.tar.gz
tar axvf protobuf-c-1.4.1.tar.gz
cd protobuf-c-1.4.1
./configure CC=${CROSS_GCC} --host=armv7 --prefix=$(pwd)/build-output --disable-protoc
make
make install
cd ..

## Extras
# -----------------------------------------------------------------------------
curl -LO https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.3.tar.gz
tar axvf ncurses-6.3.tar.gz
cd ncurses-6.3
./configure CC=${CROSS_GCC} --host=armv7 --prefix=$(pwd)/build-output
make
make install
cd ..

curl -LO https://ftp.gnu.org/gnu/screen/screen-4.9.0.tar.gz
tar axvf screen-4.9.0.tar.gz
cd screen-4.9.0
sh autogen.sh
sed -i 's!-lncurses !-l:${BASE_DIR}/ncurses-6.3/build-output/lib/libncurses.a!g' configure.ac
./configure CC=${CROSS_GCC} --host=armv7 --prefix=$(pwd)/build-output --enable-colors256 \
            CFLAGS="-I${BASE_DIR}/ncurses-6.3/build-output/include -L${BASE_DIR}/ncurses-6.3/build-output/lib -l:${BASE_DIR}/ncurses-6.3/build-output/lib/libncurses.a"
make
make install
cd ..

## VNC Server
# -------------------------------------------------------------------------------
curl -LO https://github.com/LibVNC/libvncserver/archive/refs/tags/LibVNCServer-0.9.14.tar.gz
tar axvf LibVNCServer-0.9.14.tar.gz
cd libvncserver-LibVNCServer-0.9.14
mkdir build
cd build
cmake -DWITH_SYSTEMD=OFF -DWITH_GNUTLS=OFF -DWITH_OPENSSL=OFF -DWITH_FFMPEG=OFF -DCMAKE_C_COMPILER="${CROSS_GCC}" -DCMAKE_FIND_ROOT_PATH="${CROSS_ROOT}" -DCMAKE_C_FLAGS="-I${CROSS_ROOT}/include" -DCMAKE_INSTALL_PREFIX="$(pwd)/../build-output" ..
make CC=${CROSS_GCC}
cd ../..

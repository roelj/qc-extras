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
CROSS_GCC_PREFIX="${CROSS_GCC::-3}"
CROSS_ROOT=${CROSS_GCC::-26} # CROSS_GCC without "/bin/arm-linux-gnueabi-gcc"
BASE_DIR="$(pwd)"
BUILD_OUTPUT_DIR="${BASE_DIR}/sysroot"

## libunistring
## ----------------------------------------------------------------------------
curl -LO https://ftp.gnu.org/gnu/libunistring/libunistring-1.1.tar.gz
tar axvf libunistring-1.1.tar.gz
cd libunistring-1.1
./configure CC=${CROSS_GCC} --host=armv7 --prefix="${BUILD_OUTPUT_DIR}"
make
make install
cd ..

## GMP
## ----------------------------------------------------------------------------
curl -LO https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz
tar axvf gmp-6.2.1.tar.xz
cd gmp-6.2.1
./configure CC=${CROSS_GCC} --host=arm-linux-gnueabi --prefix="${BUILD_OUTPUT_DIR}"
make
make install
cd ..

## Nettle
## ----------------------------------------------------------------------------
curl -LO https://ftp.gnu.org/gnu/nettle/nettle-3.8.1.tar.gz
tar axvf nettle-3.8.1.tar.gz
cd nettle-3.8.1
./configure CC=${CROSS_GCC} CFLAGS="-I${BUILD_OUTPUT_DIR}/include -L${BUILD_OUTPUT_DIR}/lib" --host=arm-linux-gnueabi --prefix="${BUILD_OUTPUT_DIR}"
make
make install
cd ..

## LIBCURL
# -----------------------------------------------------------------------------
# Build without SSL, we will use the library installed on the Quad Cortex
# instead of this one.  However, we need to have the header files and link
# to the library at compile-time.

curl -LO https://curl.se/download/curl-7.86.0.tar.gz
tar axvf curl-7.86.0.tar.gz
cd curl-7.86.0
./configure CC=${CROSS_GCC} --host=armv7 --prefix="${BUILD_OUTPUT_DIR}" --without-ssl
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
./configure CC=${CROSS_GCC} --host=armv7 --prefix="${BUILD_OUTPUT_DIR}" --enable-itc=pipe
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
./configure CC=${CROSS_GCC} --host=armv7 --prefix="${BUILD_OUTPUT_DIR}" --disable-protoc
make
make install
cd ..

## Extras
# -----------------------------------------------------------------------------
curl -LO https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.3.tar.gz
tar axvf ncurses-6.3.tar.gz
cd ncurses-6.3
./configure CC=${CROSS_GCC} --host=armv7 --prefix="${BUILD_OUTPUT_DIR}"
make
make install
cd ..

curl -LO https://ftp.gnu.org/gnu/screen/screen-4.9.0.tar.gz
tar axvf screen-4.9.0.tar.gz
cd screen-4.9.0
sh autogen.sh
sed -i 's!-lncurses !-l:${BUILD_OUTPUT_DIR}/lib/libncurses.a!g' configure.ac
./configure CC=${CROSS_GCC} --host=armv7 --prefix="${BUILD_OUTPUT_DIR}" --enable-colors256 \
            CFLAGS="-I${BUILD_OUTPUT_DIR}/include -L${BUILD_OUTPUT_DIR}/lib -l:${BUILD_OUTPUT_DIR}/lib/libncurses.a"
make
make install
cd ..

## strace
## ----------------------------------------------------------------------------
curl -LO https://github.com/strace/strace/releases/download/v6.1/strace-6.1.tar.xz
tar axvf strace-6.1.tar.xz
cd strace-6.1
./configure CC=${CROSS_GCC} --host=armv7 --prefix="${BUILD_OUTPUT_DIR}"
make
make install
cd ..

## OpenSSL
# -----------------------------------------------------------------------------
curl -LO https://www.openssl.org/source/openssl-1.1.1s.tar.gz
tar axvf openssl-1.1.1s.tar.gz
cd openssl-1.1.1s
./Configure linux-generic32 shared --cross-compile-prefix="${CROSS_GCC_PREFIX}" --prefix="${BUILD_OUTPUT_DIR}" --openssldir="${BUILD_OUTPUT_DIR}"
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
cmake -DWITH_SYSTEMD=OFF -DWITH_GNUTLS=OFF -DWITH_OPENSSL=OFF -DWITH_FFMPEG=OFF -DCMAKE_C_COMPILER="${CROSS_GCC}" -DCMAKE_FIND_ROOT_PATH="${CROSS_ROOT}" -DCMAKE_C_FLAGS="-I${CROSS_ROOT}/include" -DCMAKE_INSTALL_PREFIX="${BUILD_OUTPUT_DIR}" ..
make CC=${CROSS_GCC}
cd ../..

## Python 3
## ------------------------------------------------------------------------------
curl -LO https://www.python.org/ftp/python/3.11.1/Python-3.11.1.tgz
tar axvf Python-3.11.1.tgz
cd Python-3.11.1
printf "ac_cv_file__dev_ptmx=no\nac_cv_file__dev_ptc=no\n" > config.site
CONFIG_SITE=config.site ./configure CC=${CROSS_GCC} --host=arm-linux-gnueabi --build="$(uname -m)" --prefix="${BUILD_OUTPUT_DIR}" --with-build-python --disable-ipv6 --enable-optimizations
make
make install
cd ..

## ZLIB
## ------------------------------------------------------------------------------
curl -LO https://www.zlib.net/zlib-1.2.13.tar.gz
tar axvf zlib-1.2.13.tar.gz
cd zlib-1.2.13
CROSS_PREFIX="${CROSS_GCC_PREFIX}" ./configure --prefix="${BUILD_OUTPUT_DIR}"
make
make install
cd ..

## XZ
## ------------------------------------------------------------------------------
curl -LO https://tukaani.org/xz/xz-5.4.1.tar.gz
tar axvf xz-5.4.1.tar.gz
cd xz-5.4.1
./configure CC=${CROSS_GCC} --host=armv7 --prefix="${BUILD_OUTPUT_DIR}"
make
make install
cd ..

## LIBXML2
## ------------------------------------------------------------------------------
curl -LO https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.14.tar.xz
tar axvf libxml2-2.9.14.tar.xz
cd libxml2-2.9.14
./configure CC=${CROSS_GCC} --host=armv7 --without-python --prefix="${BUILD_OUTPUT_DIR}" CFLAGS="-I${BUILD_OUTPUT_DIR}/include -L${BUILD_OUTPUT_DIR}/lib"
make
make install
cd ..


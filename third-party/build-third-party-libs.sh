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

## LIBCURL
# -----------------------------------------------------------------------------
# Build without SSL, we will use the library installed on the Quad Cortex
# instead of this one.  However, we need to have the header files and link
# to the library at compile-time.

curl -LO https://curl.se/download/curl-7.86.0.tar.gz
tar axvf curl-7.86.0.tar.gz
cd curl-7.86.0
./configure CC=${CROSS_GCC} --host=armv7 --prefix=$(pwd)/build-output --without-ssl --prefix=$(pwd)/build-output
make
make install

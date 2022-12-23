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

AUTOMAKE_OPTIONS      = subdir-objects
SUBDIRS               = .

bin_PROGRAMS          = qc-controller
qc_controller_CFLAGS  = -I$(top_srcdir)/third-party/curl-7.86.0/build-output/include \
                        -I${top_srcdir}/third-party/libmicrohttpd-0.9.75/build-output/include \
                        -I${top_srcdir}/third-party/protobuf-c-1.4.1/build-output/include \
                        -I$(top_srcdir)/include -pthread
qc_controller_LDADD   = -L$(top_srcdir)/third-party/curl-7.86.0/build-output/lib -lcurl \
                        -l:${top_srcdir}/third-party/libmicrohttpd-0.9.75/build-output/lib/libmicrohttpd.a \
                        -l:${top_srcdir}/third-party/protobuf-c-1.4.1/build-output/lib/libprotobuf-c.a
qc_controller_SOURCES = src/main.c                     \
                        src/runtime_configuration.c    \
                        src/ui.c

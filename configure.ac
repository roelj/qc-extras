dnl Copyright © 2022 Roel Janssen <roel@roelj.com>
dnl
dnl This program is free software: you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation, either version 3 of the License, or
dnl (at your option) any later version.
dnl
dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program. If not, see <http://www.gnu.org/licenses/>.
dnl -*- Autoconf -*-

AC_INIT(qc-development, 0.0.1)
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([color-tests -Wall -Wno-portability foreign])
AM_SILENT_RULES([yes])

LT_INIT([dlopen win32-dll])
AC_SUBST([LIBTOOL_DEPS])

AC_PROG_CC
AM_PROG_CC_C_O
AC_CHECK_HEADERS([stdlib.h stdio.h])

AC_CONFIG_FILES([Makefile])

AC_OUTPUT

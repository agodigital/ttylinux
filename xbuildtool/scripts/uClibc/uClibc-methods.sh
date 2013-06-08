#!/bin/bash


# This file is NOT part of the kegel-initiated cross-tools software.
# This file is NOT part of the crosstool-NG software.
# This file IS part of the ttylinux xbuildtool software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2011-2013 Douglas Jerome <douglas@ttylinux.org>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA


# *****************************************************************************
#
# PROGRAM INFORMATION
#
#	Developed by:	xbuildtool project
#	Developer:	Douglas Jerome, drj, <douglas@ttylinux.org>
#
# FILE DESCRIPTION
#
#	This script builds the cross-development uClibc.
#
# CHANGE LOG
#
#	03jun13	drj	Reorganize xbuildtool files.  Scrub architecture.
#	05dec12	drj	Added the XBT_*_EXT variables.
#	19feb12	drj	Added text manifest of tool chain components.
#	01jan11	drj	Initial version from ttylinux cross-tools.
#
# *****************************************************************************


# *****************************************************************************
# libc_resolve_name
# *****************************************************************************

# Usage: libc_resolve_name <string>
#
# Uses:
#      XBT_SCRIPT_DIR
#      uClibc-versions.sh
#
# Sets:
#     XBT_LIBC
#     XBT_LIBC_EXT
#     XBT_LIBC_MD5SUM
#     XBT_LIBC_URL

declare XBT_LIBC=""
declare XBT_LIBC_EXT=""
declare XBT_LIBC_MD5SUM=""
declare XBT_LIBC_URL=""

libc_resolve_name() {

source ${XBT_SCRIPT_DIR}/uClibc/uClibc-versions.sh

local -r  uClibcNameVer=${1}    # delare read-only
local -ir rcount=${#_UCLIBC[@]} # delare integer, read-only
local -i  i=0                   # delare integer

for (( i=0 ; i<${#_UCLIBC[@]} ; i++ )); do
	if [[ "${uClibcNameVer}" == "${_UCLIBC[$i]}" ]]; then
		XBT_LIBC="${_UCLIBC[$i]}"
		XBT_LIBC_EXT="${_UCLIBC_EXT[$i]}"
		XBT_LIBC_MD5SUM="${_UCLIBC_MD5SUM[$i]}"
		XBT_LIBC_URL="${_UCLIBC_URL[$i]}"
		break # for loop
	fi
done

unset _UCLIBC
unset _UCLIBC_EXT
unset _UCLIBC_MD5SUM
unset _UCLIBC_URL

if [[ -z "${XBT_LIBC}" ]]; then
	echo "E> Cannot resolve \"${uClibcNameVer}\""
	return 1
fi

return 0

}


# *****************************************************************************
# libc_stage1_build
# *****************************************************************************

# Build and install the cross-built target uClibc header files and a few object
# files, which later can be used to build a better cross-compiling GCC.

libc_stage1_build() {

local msg="Building ${XBT_LIBC} Stage 1 "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_40 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

xbt_debug_break "" >&${CONSOLE_FD}

# Find, uncompress and untarr ${XBT_LIBC}.   The second argument is a secondary
# location to copy the source code tarball; this is so that users of the cross
# tool chain have access to the Linux source code as any users likely will
# cross-build the Linux kernel.
#
xbt_src_get ${XBT_LIBC} "${XBT_XSRC_DIR}"
unset _name # from xbt_src_get()

# Make manifest entries.
#
echo -n "${XBT_LIBC} " >>"${XBT_TOOLCHAIN_MANIFEST}"
echo -n "${XBT_LIBC} " >>"${XBT_TARGET_MANIFEST}"
for ((i=(40-${#XBT_LIBC}) ; i > 0 ; i--)) do
	echo -n "." >>"${XBT_TOOLCHAIN_MANIFEST}"
	echo -n "." >>"${XBT_TARGET_MANIFEST}"
done
echo " ${XBT_LIBC_URL}" >>"${XBT_TOOLCHAIN_MANIFEST}"
echo " ${XBT_LIBC_URL}" >>"${XBT_TARGET_MANIFEST}"
#
_cfg="${XBT_LIBC}-${XBT_TARGET%%-*}.cfg"
cp "${XBT_CONFIG_DIR}/${_cfg}" "${XBT_XSRC_DIR}"
chmod 644 "${XBT_XSRC_DIR}/${XBT_LIBC}"*.cfg
echo "=> config: ${_cfg}" >>"${XBT_TOOLCHAIN_MANIFEST}"
echo "=> config: ${_cfg}" >>"${XBT_TARGET_MANIFEST}"
unset _cfg

# Get the uClibc config file.  Set the KERNEL_HEADERS to the right place.
#
cp -v ${XBT_CONFIG_DIR}/${XBT_LIBC}-${XBT_TARGET%%-*}.cfg ${XBT_LIBC}/.config
sed -e "s|\(KERNEL_HEADERS=\)\".*\"|\1\"${XBT_XTARG_DIR}/usr/include\"|" \
	-i ${XBT_LIBC}/.config

# Use any patches; make manifest entries.
#
cd ${XBT_LIBC}
for p in ${XBT_SCRIPT_DIR}/uClibc/${XBT_LIBC}-*.patch; do
	if [[ -f "${p}" ]]; then
		patch -Np1 -i "${p}"
		cp "${p}" "${XBT_XSRC_DIR}"
		_p="$(basename ${p})"
		chmod 644 "${XBT_XSRC_DIR}/${_p}"
		echo "=> patch: ${_p}" >>"${XBT_TOOLCHAIN_MANIFEST}"
		echo "=> patch: ${_p}" >>"${XBT_TARGET_MANIFEST}"
		unset _p
	fi
done; unset p
cd ..

cd ${XBT_LIBC}

# Install uClibc header files.
#
echo "#: *********************************************************************"
echo "#: XBT_INSTALL"
echo "#: *********************************************************************"
xbt_files_timestamp
#
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make \
	CROSS="${XBT_TARGET}-" \
	PREFIX="${XBT_XTARG_DIR}/" \
	headers
#
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make \
	CROSS="${XBT_TARGET}-" \
	PREFIX="${XBT_XTARG_DIR}/" \
	install_headers
#
# So far, for uClibc, only header files have been installed.  The next GCC
# build step will need the following three object files; manually build and
# install them.
mkdir -p "${XBT_XTARG_DIR}/lib"
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make \
	CROSS="${XBT_TARGET}-" \
	PREFIX="${XBT_XTARG_DIR}/" \
	STRIPTOOL=true \
	lib/crt1.o lib/crti.o lib/crtn.o || exit 1
INSTCMD="install --group=$(id -g) --owner=$(id -u)"
${INSTCMD} --mode=755 lib/crt1.o ${XBT_XTARG_DIR}/lib
${INSTCMD} --mode=755 lib/crti.o ${XBT_XTARG_DIR}/lib
${INSTCMD} --mode=755 lib/crtn.o ${XBT_XTARG_DIR}/lib
unset INSTCMD
#
# The next GCC build step will need libc.so, maybe for libgcc_s.so, but libc.so
# cannot yet be built.  The solution is to create an empty libc.so so that the
# next version of the cross-compiling GCC can be built.
#
# Diversion:  The final cross-compiling GCC cannot use the empty libc.so that
#             is being built here; therefore, the next GCC build step will
#             still create an incomplete GCC.
#
# Use /dev/null as a C source file to create an empty libc.so.
[[ "${XBT_LINUX_ARCH}" = "x86_64" ]] && CFLAG="-m64" || CFLAG=""
mkdir -p "${XBT_XTARG_DIR}/lib"
${XBT_XHOST_DIR}/usr/bin/${XBT_TARGET}-gcc ${CFLAG} \
	-nostdlib -nostartfiles -shared -x c /dev/null \
	-o ${XBT_XTARG_DIR}/lib/libc.so || exit 1
#${XBT_XHOST_DIR}/usr/bin/${XBT_TARGET}-gcc ${CFLAG} \
#	-nostdlib -nostartfiles -shared -x c /dev/null \
#	-o ${XBT_XTARG_DIR}/lib/libm.so || exit 1
unset CFLAG

xbt_debug_break "installed ${XBT_LIBC} for stage 1" >&${CONSOLE_FD}

echo "#: *********************************************************************"
echo "#: XBT_FILES"
echo "#: *********************************************************************"
xbt_files_find

# Move out and clean up.
#
cd ..
rm -rf "${XBT_LIBC}"

echo "done" >&${CONSOLE_FD}

return 0

}


# *****************************************************************************
# libc_stage2_build
# *****************************************************************************

# This procedure builds and installs the full uClibc
#
# A fairly complete GCC cross-compiler is available; it does not have a proper
# libgcc_s.so, but that is assumed to not be needed to cross build a final and
# complete target uClibc.

libc_stage2_build() {

local msg="Building ${XBT_LIBC} Stage 2 "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_40 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

xbt_debug_break "" >&${CONSOLE_FD}

# Find, uncompress and untarr ${XBT_LIBC}.
#
xbt_src_get ${XBT_LIBC}
unset _name

# Get the uClibc config file.  Set the KERNEL_HEADERS to the right place.
#
cp -v ${XBT_CONFIG_DIR}/${XBT_LIBC}-${XBT_TARGET%%-*}.cfg ${XBT_LIBC}/.config
sed -e "s|\(KERNEL_HEADERS=\)\".*\"|\1\"${XBT_XTARG_DIR}/usr/include\"|" \
	-i ${XBT_LIBC}/.config

cd ${XBT_LIBC}
for p in ${XBT_SCRIPT_DIR}/uClibc/${XBT_LIBC}-*.patch; do
	if [[ -f "${p}" ]]; then patch -Np1 -i "${p}"; fi
done; unset p
cd ..

cd ${XBT_LIBC}

# Install uClibc.
#
echo "#: *********************************************************************"
echo "#: XBT_INSTALL"
echo "#: *********************************************************************"
xbt_files_timestamp
#
rm -f ${XBT_XTARG_DIR}/lib/libc.so # Remove the empty libc.so.
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make -j1 \
	CROSS=${XBT_TARGET}- \
	PREFIX="${XBT_XTARG_DIR}/" \
	STRIPTOOL=true \
	pregen || exit 1
#
njobs=$((${ncpus} + 1)) # If there are multiple host cpus, do parallel making.
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make -j${njobs} \
	CROSS=${XBT_TARGET}- \
	PREFIX="${XBT_XTARG_DIR}/" \
	STRIPTOOL=true \
	all || exit 1
unset njobs
#
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make \
	CROSS=${XBT_TARGET}- \
	PREFIX="${XBT_XTARG_DIR}/" \
	STRIPTOOL=true \
	utils || exit 1 # for ldd, ldconfig, ...
#
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make \
	CROSS=${XBT_TARGET}- \
	PREFIX="${XBT_XTARG_DIR}/" \
	STRIPTOOL=true \
	install || exit 1
#
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make \
	CROSS=${XBT_TARGET}- \
	PREFIX="${XBT_XTARG_DIR}/" \
	STRIPTOOL=true \
	install_utils || exit 1

echo "#: *********************************************************************"
echo "#: XBT_FILES"
echo "#: *********************************************************************"
xbt_files_find

xbt_debug_break "installed ${XBT_LIBC} for stage 2" >&${CONSOLE_FD}

# Move out and clean up.
#
cd ..
rm -rf "${XBT_LIBC}"

echo "done [${XBT_LIBC} is complete]" >&${CONSOLE_FD}

return 0

}


# *****************************************************************************
# libc_stage3_build
# *****************************************************************************

libc_stage3_build() {

echo "# ********** Not implemented.  Maybe it should be."
return 0

}


# end of file

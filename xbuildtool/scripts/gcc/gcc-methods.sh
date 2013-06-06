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
#	This script builds the cross-development GCC.
#
# CHANGE LOG
#
#	03jun13	drj	Reorganize xbuildtool files.  Scrub architecture.
#	05jan13	drj	Added gcc 4.6.3.
#	07dec12	drj	Added cloog and ppl support.
#	05dec12	drj	Added the XBT_*_EXT variables.
#	27mar12	drj	Fixed to not link libgcc_s with libc.  My head hurts.
#	19feb12	drj	Added text manifest of tool chain components.
#	11feb12	drj	Minor fussing.
#	10feb12	drj	Added libraries.
#	10feb12	drj	Added debug breaks.
#	01jan11	drj	Initial version from ttylinux cross-tools.
#
# *****************************************************************************


# *****************************************************************************
# gcc_lib_cloog_build
# *****************************************************************************

gcc_lib_cloog_build() {
:
}


# *****************************************************************************
# gcc_lib_gmp_build
# *****************************************************************************

gcc_lib_gmp_build() {

local XBT_GMP=${XBT_GCC_LIBS[$1]}
local XBT_GMP_URL=${XBT_GCC_LIBS_URL[$1]}

local msg="Building ${XBT_GMP} "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_40 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

xbt_debug_break "" >&${CONSOLE_FD}

# Find, uncompress and untar ${XBT_GMP}.  The second argument is a
# secondary location to copy the source code tarball; this is so that users of
# the cross tool chain have access to the Linux source code as any users likely
# will cross-build the Linux kernel.
#
xbt_src_get ${XBT_GMP}
unset _name # from xbt_src_get()

# Make an entry in the manifest.
#
echo -n "${XBT_GMP} " >>"${XBT_TOOLCHAIN_MANIFEST}"
for ((i=(40-${#XBT_GMP}) ; i > 0 ; i--)) do
	echo -n "." >>"${XBT_TOOLCHAIN_MANIFEST}"
done; unset i
echo " ${XBT_BINUTILS_URL}" >>"${XBT_TOOLCHAIN_MANIFEST}"

# Get in there.
#
cd ${XBT_GMP}

# Configure GMP for building.
#
echo "#: *********************************************************************"
echo "#: XBT_CONFIG"
echo "#: *********************************************************************"
CFLAGS="-fexceptions" ./configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--prefix=${XBT_XHOST_DIR}/usr \
	--enable-cxx \
	--enable-fft \
	--enable-mpbsd \
	--enable-static \
	--disable-shared || exit 1

xbt_debug_break "configured ${XBT_GMP}" >&${CONSOLE_FD}

# Build GMP.
#
echo "#: *********************************************************************"
echo "#: XBT_MAKE"
echo "#: *********************************************************************"
njobs=$((${ncpus} + 1))
make -j ${njobs} || exit 1
unset njobs

xbt_debug_break "maked ${XBT_GMP}" >&${CONSOLE_FD}

# Install GMP.
#
echo "#: *********************************************************************"
echo "#: XBT_INSTALL"
echo "#: *********************************************************************"
xbt_files_timestamp
make install || exit 1

echo "#: *********************************************************************"
echo "#: XBT_FILES"
echo "#: *********************************************************************"
xbt_files_find

xbt_debug_break "installed ${XBT_GMP}" >&${CONSOLE_FD}

# Move out and clean up.
#
cd ..
rm -rf "${XBT_GMP}"

echo "done [${XBT_GMP} is complete]" >&${CONSOLE_FD}

return 0

}


# *****************************************************************************
# gcc_lib_mpc_build
# *****************************************************************************

gcc_lib_mpc_build() {
:
}


# *****************************************************************************
# gcc_lib_mpfr_build
# *****************************************************************************

gcc_lib_mpfr_build() {
:
}


# *****************************************************************************
# gcc_lib_ppl_build
# *****************************************************************************

gcc_lib_ppl_build() {
:
}



# *****************************************************************************
# gcc_resolve_name
# *****************************************************************************

# Usage: gcc_resolve_name <string>
#
# Uses:
#      XBT_SCRIPT_DIR
#      gcc-versions.sh
#
# Sets:
#     XBT_GCC_LIBS[]
#     XBT_GCC_LIBS_EXT[]
#     XBT_GCC_LIBS_MD5SUM[]
#     XBT_GCC_LIBS_URL[]
#     XBT_GCC
#     XBT_GCC_EXT
#     XBT_GCC_MD5SUM
#     XBT_GCC_URL

declare -a XBT_GCC_LIBS        # declare indexed array
declare -a XBT_GCC_LIBS_EXT    # declare indexed array
declare -a XBT_GCC_LIBS_MD5SUM # declare indexed array
declare -a XBT_GCC_LIBS_URL    # declare indexed array

declare XBT_GCC=""
declare XBT_GCC_EXT=""
declare XBT_GCC_MD5SUM=""
declare XBT_GCC_URL=""

gcc_resolve_name() {

source ${XBT_SCRIPT_DIR}/gcc/gcc-versions.sh

local -r  gccNameVer=${1}    # delare read-only
local -ir rcount=${#_GCC[@]} # delare integer, read-only
local -i  i=0                # delare integer
local -i  j=0                # delare integer

for (( i=0 ; i<${rcount} ; i++ )); do
	if [[ "${gccNameVer}" == "${_GCC[$i]}" ]]; then
		if [[ -n "${_CLOOG[$i]}" ]]; then
			XBT_GCC_LIBS[$j]="${_CLOOG[$i]}"
			XBT_GCC_LIBS_EXT[$j]="${_CLOOG_EXT[$i]}"
			XBT_GCC_LIBS_MD5SUM[$j]="${_CLOOG_MD5SUM[$i]}"
			XBT_GCC_LIBS_URL[$j]="${_CLOOG_URL[$i]}"
			j=$(($j + 1))
		fi
		if [[ -n "${_GMP[$i]}" ]]; then
			XBT_GCC_LIBS[$j]="${_GMP[$i]}"
			XBT_GCC_LIBS_EXT[$j]="${_GMP_EXT[$i]}"
			XBT_GCC_LIBS_MD5SUM[$j]="${_GMP_MD5SUM[$i]}"
			XBT_GCC_LIBS_URL[$j]="${_GMP_URL[$i]}"
			j=$(($j + 1))
		fi
		if [[ -n "${_MPC[$i]}" ]]; then
			XBT_GCC_LIBS[$j]="${_MPC[$i]}"
			XBT_GCC_LIBS_EXT[$j]="${_MPC_EXT[$i]}"
			XBT_GCC_LIBS_MD5SUM[$j]="${_MPC_MD5SUM[$i]}"
			XBT_GCC_LIBS_URL[$j]="${_MPC_URL[$i]}"
			j=$(($j + 1))
		fi
		if [[ -n "${_MPFR[$i]}" ]]; then
			XBT_GCC_LIBS[$j]="${_MPFR[$i]}"
			XBT_GCC_LIBS_EXT[$j]="${_MPFR_EXT[$i]}"
			XBT_GCC_LIBS_MD5SUM[$j]="${_MPFR_MD5SUM[$i]}"
			XBT_GCC_LIBS_URL[$j]="${_MPFR_URL[$i]}"
			j=$(($j + 1))
		fi
		if [[ -n "${_PPL[$i]}" ]]; then
			XBT_GCC_LIBS[$j]="${_PPL[$i]}"
			XBT_GCC_LIBS_EXT[$j]="${_PPL_EXT[$i]}"
			XBT_GCC_LIBS_MD5SUM[$j]="${_PPL_MD5SUM[$i]}"
			XBT_GCC_LIBS_URL[$j]="${_PPL_URL[$i]}"
			j=$(($j + 1))
		fi
                XBT_GCC="${_GCC[$i]}"
                XBT_GCC_EXT="${_GCC_EXT[$i]}"
                XBT_GCC_MD5SUM="${_GCC_MD5SUM[$i]}"
                XBT_GCC_URL="${_GCC_URL[$i]}"
		break # for loop
	fi
done

unset _CLOOG
unset _CLOOG_EXT
unset _CLOOG_MD5SUM
unset _CLOOG_URL

unset _GMP
unset _GMP_EXT
unset _GMP_MD5SUM
unset _GMP_URL

unset _MPC
unset _MPC_EXT
unset _MPC_MD5SUM
unset _MPC_URL

unset _MPFR
unset _MPFR_EXT
unset _MPFR_MD5SUM
unset _MPFR_URL

unset _PPL
unset _PPL_EXT
unset _PPL_MD5SUM
unset _PPL_URL

unset _GCC
unset _GCC_EXT
unset _GCC_MD5SUM
unset _GCC_URL

if [[ -z "${XBT_GCC}" ]]; then
	echo "E> Cannot resolve \"${gccNameVer}\""
	return 1
fi

return 0

}


# end of file

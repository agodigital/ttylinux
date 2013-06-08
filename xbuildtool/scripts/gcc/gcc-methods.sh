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
#	08jun13	drj	Took out gcc 4.4.6 and 4.6.3; added 4.4.7 and 4.6.4.
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

local XBT_CLOOG=${XBT_GCC_LIBS[$1]}
local XBT_CLOOG_URL=${XBT_GCC_LIBS_URL[$1]}

local msg="Building ${XBT_CLOOG} "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_40 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

xbt_debug_break "" >&${CONSOLE_FD}

# Find, uncompress and untar ${XBT_CLOOG}.
#
xbt_src_get ${XBT_CLOOG}
unset _name # from xbt_src_get()

# Make an entry in the manifest.
#
echo -n "${XBT_CLOOG} " >>"${XBT_TOOLCHAIN_MANIFEST}"
for ((i=(40-${#XBT_CLOOG}) ; i > 0 ; i--)) do
	echo -n "." >>"${XBT_TOOLCHAIN_MANIFEST}"
done; unset i
echo " ${XBT_BINUTILS_URL}" >>"${XBT_TOOLCHAIN_MANIFEST}"

# Get in there.
#
cd ${XBT_CLOOG}

# Configure CLOOG for building.
#
# http://sourceforge.net/apps/trac/mingw-w64/wiki/PPL,%20CLooG%20and%20GCC
#      CLooG/PPL:
#      "Building CLooG is straight forward. For static builds, you should add
#      '--with-host-libstdcxx="-lstdc++ -lsupc++"' to the configuration script
#      to avoid link failures."
#      2013-02-dd
#
echo "#: *********************************************************************"
echo "#: XBT_CONFIG"
echo "#: *********************************************************************"
CFLAGS="-fexceptions" ./configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--prefix=${XBT_XHOST_DIR}/usr \
	--with-gmp-prefix=${XBT_XHOST_DIR}/usr \
	--enable-static \
	--disable-shared || exit 1

xbt_debug_break "configured ${XBT_CLOOG}" >&${CONSOLE_FD}

# Build CLOOG.
#
echo "#: *********************************************************************"
echo "#: XBT_MAKE"
echo "#: *********************************************************************"
njobs=$((${ncpus} + 1))
make -j ${njobs} || exit 1
unset njobs

xbt_debug_break "maked ${XBT_CLOOG}" >&${CONSOLE_FD}

# Install CLOOG.
#
echo "#: *********************************************************************"
echo "#: XBT_INSTALL"
echo "#: *********************************************************************"
xbt_files_timestamp
make install || exit 1

echo "#: *********************************************************************"
echo "#: XBT_FILES"
echo "#: *********************************************************************"
xbt_files_find # Put the list of installed files in the log file.

xbt_debug_break "installed ${XBT_CLOOG}" >&${CONSOLE_FD}

# Move out and clean up.
#
cd ..
rm -rf "${XBT_CLOOG}"

echo "done [${XBT_CLOOG} is complete]" >&${CONSOLE_FD}

return 0

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

# Find, uncompress and untar ${XBT_GMP}.
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
xbt_files_find # Put the list of installed files in the log file.

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

local XBT_MPC=${XBT_GCC_LIBS[$1]}
local XBT_MPC_URL=${XBT_GCC_LIBS_URL[$1]}

local msg="Building ${XBT_MPC} "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_40 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

xbt_debug_break "" >&${CONSOLE_FD}

# Find, uncompress and untar ${XBT_MPC}.
#
xbt_src_get ${XBT_MPC}
unset _name # from xbt_src_get()

# Make an entry in the manifest.
#
echo -n "${XBT_MPC} " >>"${XBT_TOOLCHAIN_MANIFEST}"
for ((i=(40-${#XBT_MPC}) ; i > 0 ; i--)) do
	echo -n "." >>"${XBT_TOOLCHAIN_MANIFEST}"
done; unset i
echo " ${XBT_BINUTILS_URL}" >>"${XBT_TOOLCHAIN_MANIFEST}"

# Get in there.
#
cd ${XBT_MPC}

# Configure MPC for building.
#
echo "#: *********************************************************************"
echo "#: XBT_CONFIG"
echo "#: *********************************************************************"
./configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--prefix=${XBT_XHOST_DIR}/usr \
	--with-gmp=${XBT_XHOST_DIR}/usr \
	--with-mpfr=${XBT_XHOST_DIR}/usr \
	--enable-static \
	--disable-shared || exit 1

xbt_debug_break "configured ${XBT_MPC}" >&${CONSOLE_FD}

# Build MPC.
#
echo "#: *********************************************************************"
echo "#: XBT_MAKE"
echo "#: *********************************************************************"
njobs=$((${ncpus} + 1))
make -j ${njobs} || exit 1
unset njobs

xbt_debug_break "maked ${XBT_MPC}" >&${CONSOLE_FD}

# Install MPC.
#
echo "#: *********************************************************************"
echo "#: XBT_INSTALL"
echo "#: *********************************************************************"
xbt_files_timestamp
make install || exit 1

echo "#: *********************************************************************"
echo "#: XBT_FILES"
echo "#: *********************************************************************"
xbt_files_find # Put the list of installed files in the log file.

xbt_debug_break "installed ${XBT_MPC}" >&${CONSOLE_FD}

# Move out and clean up.
#
cd ..
rm -rf "${XBT_MPC}"

echo "done [${XBT_MPC} is complete]" >&${CONSOLE_FD}

return 0

}


# *****************************************************************************
# gcc_lib_mpfr_build
# *****************************************************************************

gcc_lib_mpfr_build() {

local XBT_MPFR=${XBT_GCC_LIBS[$1]}
local XBT_MPFR_URL=${XBT_GCC_LIBS_URL[$1]}

local msg="Building ${XBT_MPFR} "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_40 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

xbt_debug_break "" >&${CONSOLE_FD}

# Find, uncompress and untar ${XBT_MPFR}.
#
xbt_src_get ${XBT_MPFR}
unset _name # from xbt_src_get()

# Make an entry in the manifest.
#
echo -n "${XBT_MPFR} " >>"${XBT_TOOLCHAIN_MANIFEST}"
for ((i=(40-${#XBT_MPFR}) ; i > 0 ; i--)) do
	echo -n "." >>"${XBT_TOOLCHAIN_MANIFEST}"
done; unset i
echo " ${XBT_BINUTILS_URL}" >>"${XBT_TOOLCHAIN_MANIFEST}"

# Get in there.
#
cd ${XBT_MPFR}

# Configure MPFR for building.
#
echo "#: *********************************************************************"
echo "#: XBT_CONFIG"
echo "#: *********************************************************************"
./configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--prefix=${XBT_XHOST_DIR}/usr \
	--with-gmp=${XBT_XHOST_DIR}/usr \
	--enable-static \
	--disable-shared || exit 1

xbt_debug_break "configured ${XBT_MPFR}" >&${CONSOLE_FD}

# Build MPFR.
#
echo "#: *********************************************************************"
echo "#: XBT_MAKE"
echo "#: *********************************************************************"
njobs=$((${ncpus} + 1))
make -j ${njobs} || exit 1
unset njobs

xbt_debug_break "maked ${XBT_MPFR}" >&${CONSOLE_FD}

# Install MPFR.
#
echo "#: *********************************************************************"
echo "#: XBT_INSTALL"
echo "#: *********************************************************************"
xbt_files_timestamp
make install || exit 1

echo "#: *********************************************************************"
echo "#: XBT_FILES"
echo "#: *********************************************************************"
xbt_files_find # Put the list of installed files in the log file.

xbt_debug_break "installed ${XBT_MPFR}" >&${CONSOLE_FD}

# Move out and clean up.
#
cd ..
rm -rf "${XBT_MPFR}"

echo "done [${XBT_MPFR} is complete]" >&${CONSOLE_FD}

return 0

}


# *****************************************************************************
# gcc_lib_ppl_build
# *****************************************************************************

gcc_lib_ppl_build() {

local XBT_PPL=${XBT_GCC_LIBS[$1]}
local XBT_PPL_URL=${XBT_GCC_LIBS_URL[$1]}

local msg="Building ${XBT_PPL} "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_40 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

xbt_debug_break "" >&${CONSOLE_FD}

# Find, uncompress and untar ${XBT_PPL}.
#
xbt_src_get ${XBT_PPL}
unset _name # from xbt_src_get()

# Make an entry in the manifest.
#
echo -n "${XBT_PPL} " >>"${XBT_TOOLCHAIN_MANIFEST}"
for ((i=(40-${#XBT_PPL}) ; i > 0 ; i--)) do
	echo -n "." >>"${XBT_TOOLCHAIN_MANIFEST}"
done; unset i
echo " ${XBT_BINUTILS_URL}" >>"${XBT_TOOLCHAIN_MANIFEST}"

# Get in there.
#
cd ${XBT_PPL}

# Configure PPL for building.
#
echo "#: *********************************************************************"
echo "#: XBT_CONFIG"
echo "#: *********************************************************************"
CFLAGS="-fexceptions" ./configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--prefix=${XBT_XHOST_DIR}/usr \
	--with-gmp-prefix=${XBT_XHOST_DIR}/usr \
	--enable-interfaces="c cxx" \
	--enable-static \
	--enable-watchdog \
	--disable-assertions \
	--disable-debugging \
	--disable-optimization \
	--disable-ppl_lcdd \
	--disable-ppl_lcsol \
	--disable-shared || exit 1

xbt_debug_break "configured ${XBT_PPL}" >&${CONSOLE_FD}

# Build PPL.
#
echo "#: *********************************************************************"
echo "#: XBT_MAKE"
echo "#: *********************************************************************"
njobs=$((${ncpus} + 1))
make -j ${njobs} || exit 1
unset njobs

xbt_debug_break "maked ${XBT_PPL}" >&${CONSOLE_FD}

# Install PPL.
#
echo "#: *********************************************************************"
echo "#: XBT_INSTALL"
echo "#: *********************************************************************"
xbt_files_timestamp
make install || exit 1

echo "#: *********************************************************************"
echo "#: XBT_FILES"
echo "#: *********************************************************************"
xbt_files_find # Put the list of installed files in the log file.

xbt_debug_break "installed ${XBT_PPL}" >&${CONSOLE_FD}

# Move out and clean up.
#
cd ..
rm -rf "${XBT_PPL}"

echo "done [${XBT_PPL} is complete]" >&${CONSOLE_FD}

return 0

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
		#
		# The XBT_GCC_LIBS array elements are set in the order that
		# they will be built.
		#
		# 1st - gmp
		# 2nd - mpfr, uses gmp
		# 3rd - mpc, uses gmp and mpfr
		# 4th - ppl, uses gmp
		# 5th - cloog, uses gmp and maybe ppl
		#
		if [[ -n "${_GMP[$i]}" ]]; then
			XBT_GCC_LIBS[$j]="${_GMP[$i]}"
			XBT_GCC_LIBS_EXT[$j]="${_GMP_EXT[$i]}"
			XBT_GCC_LIBS_MD5SUM[$j]="${_GMP_MD5SUM[$i]}"
			XBT_GCC_LIBS_URL[$j]="${_GMP_URL[$i]}"
			j=$(($j + 1))
		fi
		if [[ -n "${_MPFR[$i]}" ]]; then
			XBT_GCC_LIBS[$j]="${_MPFR[$i]}"
			XBT_GCC_LIBS_EXT[$j]="${_MPFR_EXT[$i]}"
			XBT_GCC_LIBS_MD5SUM[$j]="${_MPFR_MD5SUM[$i]}"
			XBT_GCC_LIBS_URL[$j]="${_MPFR_URL[$i]}"
			j=$(($j + 1))
		fi
		if [[ -n "${_MPC[$i]}" ]]; then
			XBT_GCC_LIBS[$j]="${_MPC[$i]}"
			XBT_GCC_LIBS_EXT[$j]="${_MPC_EXT[$i]}"
			XBT_GCC_LIBS_MD5SUM[$j]="${_MPC_MD5SUM[$i]}"
			XBT_GCC_LIBS_URL[$j]="${_MPC_URL[$i]}"
			j=$(($j + 1))
		fi
		if [[ -n "${_PPL[$i]}" ]]; then
			XBT_GCC_LIBS[$j]="${_PPL[$i]}"
			XBT_GCC_LIBS_EXT[$j]="${_PPL_EXT[$i]}"
			XBT_GCC_LIBS_MD5SUM[$j]="${_PPL_MD5SUM[$i]}"
			XBT_GCC_LIBS_URL[$j]="${_PPL_URL[$i]}"
			j=$(($j + 1))
		fi
		if [[ -n "${_CLOOG[$i]}" ]]; then
			XBT_GCC_LIBS[$j]="${_CLOOG[$i]}"
			XBT_GCC_LIBS_EXT[$j]="${_CLOOG_EXT[$i]}"
			XBT_GCC_LIBS_MD5SUM[$j]="${_CLOOG_MD5SUM[$i]}"
			XBT_GCC_LIBS_URL[$j]="${_CLOOG_URL[$i]}"
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


# *************************************************************************** #
#                                                                             #
# http://sourceforge.net/apps/trac/mingw-w64/wiki/PPL,%20CLooG%20and%20GCC    #
#      Building GCC:                                                          #
#      "When running the GCC configure script, remember to set --with-ppl and #
#      --with-cloog to point to the PPL and CLooG install prefix.  If you are #
#      linking to static PPL and CLooG, add                                   #
#      '--with-host-libstdcxx="-lstdc++ -lsupc++"' to prevent link failures   #
#      when building the new GCC backends."                                   #
#      2013-02-dd                                                             #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# gcc_stage1_build
# *****************************************************************************

# Build a cross-compiling GCC; this will be used to cross-compile GLIBC or
# uClibc for the target system, and also then be available to cross-build any
# target packages.
#
# The complete and final cross-compiling GCC cannot yet be built because it
# seems that the GCC build process builds a libgcc_s.so, and that needs the
# GLIBC or uClibc target header files and a cross-built libc.so with which
# libgcc_s.so is linked.  The libc target header files and cross-built libc.so
# are not yet available because the cross-compiling GCC is not yet built.
#
# Note:  libgcc_s.so is a cross-built target object code file; that is why it
#        can be linked with the cross-built target libc.so.  Since the cross-
#        compiling GCC itself is not a cross-built target program, it executes
#        on the host computer not target computer, libgcc_s.so is not linked
#        to the GCC cross-compiler.  The process of cross building software
#        with a cross-compiling GCC can take parts of libgcc_s.so and put them
#        into the software being cross-compiled.
#
# Libgcc_s.so may not be the only output from the build process that has the
# problem that is described above.  Libgcc.a and libgcc_eh.a may be similar.
#
# The first GCC-building step is to build a cross-compiling GCC while not
# building libgcc_s.so.  The GCC configuration option --disable-shared avoids
# bulding any shared objects.  The GCC cross-compiling-specific configuration
# options --with-newlib, --with-sysroot and --without-headers avoid using libc
# and avoid using any library header files during the build process.  Refer to
# http://gcc.gnu.org/install/configure.html for a description of these
# configuration options.  The --without-headers option might not be needed.
#
# This preliminary version of GCC will not need several other capabilities, and
# these other capabilities may not build without GLIBC or some other C library.
# The configuration options --disable-decimal-float, --disable-libada,
# --disable-libgomp, --disable-libmudflap, --disable-libssp, --disable-multilib,
# --disable-libquadmath and --disable-threads are used to avoid building these
# as yet unneeded GCC capabilities.
#
# Also, only the C language compiler is yet used.
#
# This preliminary cross compiler can be used to install Linux and libc header
# files and make some simple target library components of GLIBC or uClibc.

gcc_stage1_build() {

local CONFIGURE_LDFLAGS=""
local CONFIGURE_ENABLES=""
local CONFIGURE_DISABLES=""
local CONFIGURE_WITHS=""
local CONFIGURE_WITHOUTS=""

local msg="Building ${XBT_GCC} Stage 1 "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_40 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

xbt_debug_break "" >&${CONSOLE_FD}

# Find, uncompress and untarr ${XBT_GCC}.
#
xbt_src_get ${XBT_GCC}
unset _name

# Make entry in the manifest.  The GCC manifest entries are made only in this
# Stage 1 procedure; the other procedure for the other GCC stages do not make
# manifest entries.
#
echo -n "${XBT_GCC} " >>"${XBT_TOOLCHAIN_MANIFEST}"
for ((i=(40-${#XBT_GCC}) ; i > 0 ; i--)) do
	echo -n "." >>"${XBT_TOOLCHAIN_MANIFEST}"
done
echo " ${XBT_GCC_URL}" >>"${XBT_TOOLCHAIN_MANIFEST}"

# Use any patches.
#
cd ${XBT_GCC}
for p in ${XBT_SCRIPT_DIR}/gcc/${XBT_GCC}-*.patch; do
	if [[ -f "${p}" ]]; then
		patch -Np1 -i "${p}"
		_p="/$(basename ${p})"
		echo "=> patch: ${_p}" >>"${XBT_TOOLCHAIN_MANIFEST}"
		unset _p
	fi
done; unset p
cd ..

# The GCC documentation recommends building GCC outside of the source directory
# in a dedicated build directory.
#
rm -rf	"build-gcc"
mkdir	"build-gcc"
cd	"build-gcc"

# GCC-4.4.7:
#
# Use sed to suppress the installation of libiberty.a; it is provided by
# binutils.
#
if [[ "${XBT_GCC}" == "gcc-4.4.7" ]]; then
	(
	# Use a subshell-- I dun know why...
	cd ../${XBT_GCC}
	sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
	)
	CONFIGURE_LDFLAGS=""
	CONFIGURE_ENABLES=""
	CONFIGURE_DISABLES=""
	CONFIGURE_WITHS="
--with-gmp=${XBT_XHOST_DIR}/usr \
--with-mpfr=${XBT_XHOST_DIR}/usr"
	CONFIGURE_WITHOUTS=""
fi

# GCC-4.6.4:
#
# Use sed to suppress the installation of libiberty.a; it is provided by
# binutils.
#
if [[ "${XBT_GCC}" == "gcc-4.6.4" ]]; then
	(
	# Use a subshell-- I dun know why...
	cd ../${XBT_GCC}
	sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
	)
	CONFIGURE_LDFLAGS="-lm -lstdc++"
	CONFIGURE_ENABLES="--enable-cloog-backend=isl"
	CONFIGURE_DISABLES="--disable-libquadmath --disable-lto"
	CONFIGURE_WITHS="\
--with-cloog=${XBT_XHOST_DIR}/usr \
--with-gmp=${XBT_XHOST_DIR}/usr \
--with-mpc=${XBT_XHOST_DIR}/usr \
--with-mpfr=${XBT_XHOST_DIR}/usr \
--with-ppl=${XBT_XHOST_DIR}/usr"
	CONFIGURE_WITHOUTS=""
fi

# Configure GCC for building.
#
echo "#: *********************************************************************"
echo "#: XBT_CONFIG"
echo "#: *********************************************************************"
LDFLAGS="${CONFIGURE_LDFLAGS}" \
../${XBT_GCC}/configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--target=${XBT_TARGET} \
	--prefix=${XBT_XHOST_DIR}/usr \
	--infodir=${XBT_XHOST_DIR}/usr/share/info \
	--mandir=${XBT_XHOST_DIR}/usr/share/man \
	--enable-languages=c \
	--enable-threads=no \
	${CONFIGURE_ENABLES} \
	--disable-decimal-float \
	--disable-libada \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libssp \
	--disable-multilib \
	--disable-shared \
	--disable-threads \
	${CONFIGURE_DISABLES} \
	--with-newlib \
	--with-sysroot=${XBT_XTARG_DIR} \
	${CONFIGURE_WITHS} \
	--without-headers \
	${CONFIGURE_WITHOUTS} || exit 1

xbt_debug_break "configured ${XBT_GCC} for stage 1" >&${CONSOLE_FD}

# Build GCC.
#
echo "#: *********************************************************************"
echo "#: XBT_MAKE"
echo "#: *********************************************************************"
njobs=$((${ncpus} + 1))
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make -j ${njobs} || exit 1
unset njobs

xbt_debug_break "maked ${XBT_GCC} for stage 1" >&${CONSOLE_FD}

# Install GCC.
#
echo "#: *********************************************************************"
echo "#: XBT_INSTALL"
echo "#: *********************************************************************"
xbt_files_timestamp
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make install || exit 1

echo "#: *********************************************************************"
echo "#: XBT_FILES"
echo "#: *********************************************************************"
xbt_files_find # Put the list of installed files in the log file.

xbt_debug_break "installed ${XBT_GCC} for stage 1" >&${CONSOLE_FD}

# Move out and clean up.
#
cd ..
rm -rf "build-gcc"
rm -rf "${XBT_GCC}"

echo "done" >&${CONSOLE_FD}

return 0

}


# *****************************************************************************
# gcc_stage2_build
# *****************************************************************************

# Build a more complete cross-compiling GCC, allowing the use of the libc
# header files and the crt1.o, crti.o and crtn.o object files.  Libgcc_s.so
# will be built and the empty cross-built target libc.so will be linked with
# it, so this version of GCC is not the complete and final version.  Since this
# is not the final and complete GCC, several other GCC capabilities that are
# not yet needed are not built; they are the same as before and configure to
# not be in the build with --disable-libada, --disable-libgomp,
# --disable-libmudflap, --disable-libssp and --disable-libquadmath.
#
# Also, only the C language compiler is yet used.

gcc_stage2_build() {

local ENABLE_THREADS=""
local CONFIGURE_LDFLAGS=""
local CONFIGURE_ENABLES=""
local CONFIGURE_DISABLES=""
local CONFIGURE_WITHS=""
local CONFIGURE_WITHOUTS=""

local msg="Building ${XBT_GCC} Stage 2 "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_40 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

xbt_debug_break "" >&${CONSOLE_FD}

# Find, uncompress and untarr ${XBT_GCC}.
#
xbt_src_get ${XBT_GCC}
unset _name

# Use any patches.
#
cd ${XBT_GCC}
for p in ${XBT_SCRIPT_DIR}/gcc/${XBT_GCC}-*.patch; do
	if [[ -f "${p}" ]]; then patch -Np1 -i "${p}"; fi
done; unset p
cd ..

# The GCC documentation recommends building GCC outside of the source directory
# in a dedicated build directory.
#
rm -rf	"build-gcc"
mkdir	"build-gcc"
cd	"build-gcc"

# Avoid linking libgcc_s with libc as this can cause a startingly big headache
# when host architecture matches target architecture.
#
(
# Use a subshell-- I dun know why...
cd ../${XBT_GCC}/gcc/config
if [[ -f t-slibgcc-elf-ver ]]; then
	sed -e "s|SHLIB_LC = -lc|SHLIB_LC =|" -i t-slibgcc-elf-ver
fi
)

# GCC-4.4.7:
#
# Use sed to suppress the installation of libiberty.a; it is provided by
# binutils.
#
if [[ "${XBT_GCC}" == "gcc-4.4.7" ]]; then
	(
	# Use a subshell-- I dun know why...
	cd ../${XBT_GCC}
	sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
	)
	CONFIGURE_LDFLAGS=""
	CONFIGURE_ENABLES=""
	CONFIGURE_DISABLES=""
	CONFIGURE_WITHS="
--with-gmp=${XBT_XHOST_DIR}/usr \
--with-mpfr=${XBT_XHOST_DIR}/usr"
	CONFIGURE_WITHOUTS=""
fi

# GCC-4.6.4:
#
# Use sed to suppress the installation of libiberty.a; it is provided by
# binutils.
#
if [[ "${XBT_GCC}" == "gcc-4.6.4" ]]; then
	(
	# Use a subshell-- I dun know why...
	cd ../${XBT_GCC}
	sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
	)
	CONFIGURE_LDFLAGS="-lm -lstdc++"
	CONFIGURE_ENABLES="--enable-cloog-backend=isl"
	CONFIGURE_DISABLES="--disable-libquadmath --disable-lto"
	CONFIGURE_WITHS="\
--with-cloog=${XBT_XHOST_DIR}/usr \
--with-gmp=${XBT_XHOST_DIR}/usr \
--with-mpc=${XBT_XHOST_DIR}/usr \
--with-mpfr=${XBT_XHOST_DIR}/usr \
--with-ppl=${XBT_XHOST_DIR}/usr"
	CONFIGURE_WITHOUTS=""
fi

ENABLE_THREADS="--disable-threads"
[[ "${XBT_THREAD_MODEL}" == "nptl" ]] && ENABLE_THREADS="--enable-threads"

# Configure GCC for building.
#
echo "#: *********************************************************************"
echo "#: XBT_CONFIG"
echo "#: *********************************************************************"
LDFLAGS="${CONFIGURE_LDFLAGS}" \
../${XBT_GCC}/configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--target=${XBT_TARGET} \
	--prefix=${XBT_XHOST_DIR}/usr \
	--infodir=${XBT_XHOST_DIR}/usr/share/info \
	--mandir=${XBT_XHOST_DIR}/usr/share/man \
	--enable-languages=c \
	--enable-shared \
	${ENABLE_THREADS} \
	${CONFIGURE_ENABLES} \
	--disable-libada \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libssp \
	--disable-multilib \
	${CONFIGURE_DISABLES} \
	--with-headers=${XBT_XTARG_DIR}/usr/include \
	--with-sysroot=${XBT_XTARG_DIR} \
	${CONFIGURE_WITHS} \
	${CONFIGURE_WITHOUTS} || exit 1

xbt_debug_break "configured ${XBT_GCC} for stage 2" >&${CONSOLE_FD}

# Build GCC.
#
echo "#: *********************************************************************"
echo "#: XBT_MAKE"
echo "#: *********************************************************************"
njobs=$((${ncpus} + 1))
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make -j ${njobs} || exit 1
unset njobs

xbt_debug_break "maked ${XBT_GCC} for stage 2" >&${CONSOLE_FD}

# Install GCC.
#
echo "#: *********************************************************************"
echo "#: XBT_INSTALL"
echo "#: *********************************************************************"
xbt_files_timestamp
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make install || exit 1

echo "#: *********************************************************************"
echo "#: XBT_FILES"
echo "#: *********************************************************************"
xbt_files_find # Put the list of installed files in the log file.

xbt_debug_break "installed ${XBT_GCC} for stage 2" >&${CONSOLE_FD}

# Move out and clean up.
#
cd ..
rm -rf "build-gcc"
rm -rf "${XBT_GCC}"

echo "done" >&${CONSOLE_FD}

return 0

}

# *****************************************************************************
# gcc_stage3_build
# *****************************************************************************

# There now is a complete and final cross-built target libc, either GLIBC or
# uClibc; the header files and target libraries are installed; now configure
# and build a cross-compiling GCC with the complete and final cross-built
# target libc.
#
# The C, C99 and C++ language compilers can be built.
#
# Note:  Several capabilities are not built; these might be not applicable for
#        cross-build GCC or they may be wanted but fail to build, or there may
#        be no good reason for not building them.  They are avoided with
#        --disable-libada, --disable-libgomp, --disable-libmudflap and
#        --disable-libssp.

gcc_stage3_build() {

local ENABLE__CXA_ATEXIT=
local ENABLE_LANGUAGES=
local ENABLE_THREADS=
local CONFIGURE_LDFLAGS=""
local CONFIGURE_ENABLES=""
local CONFIGURE_DISABLES=""
local CONFIGURE_WITHS=""
local CONFIGURE_WITHOUTS=""

local msg="Building ${XBT_GCC} Stage 3 "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_40 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

xbt_debug_break "" >&${CONSOLE_FD}

# Find, uncompress and untarr ${XBT_GCC}.
#
xbt_src_get ${XBT_GCC}
unset _name

# Use any patches.
#
cd ${XBT_GCC}
for p in ${XBT_SCRIPT_DIR}/gcc/${XBT_GCC}-*.patch; do
	if [[ -f "${p}" ]]; then patch -Np1 -i "${p}"; fi
done; unset p
cd ..

# The GCC documentation recommends building GCC outside of the source directory
# in a dedicated build directory.
#
rm -rf	"build-gcc"
mkdir	"build-gcc"
cd	"build-gcc"

# Avoid linking libgcc_s with libc as this can cause a startingly big headache
# when host architecture matches target architecture.
#
(
# Use a subshell-- I dun know why...
cd ../${XBT_GCC}/gcc/config
if [[ -f t-slibgcc-elf-ver ]]; then
	sed -e "s|SHLIB_LC = -lc|SHLIB_LC =|" -i t-slibgcc-elf-ver
fi
)

# GCC-4.4.7:
#
# Use sed to suppress the installation of libiberty.a; it is provided by
# binutils.
#
if [[ "${XBT_GCC}" == "gcc-4.4.7" ]]; then
	(
	# Use a subshell-- I dun know why...
	cd ../${XBT_GCC}
	sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
	)
	CONFIGURE_LDFLAGS="-lm -lstdc++"
	CONFIGURE_ENABLES=""
	CONFIGURE_DISABLES=""
	CONFIGURE_WITHS="
--with-gmp=${XBT_XHOST_DIR}/usr \
--with-mpfr=${XBT_XHOST_DIR}/usr"
	CONFIGURE_WITHOUTS=""
fi

# GCC-4.6.4:
#
# Use sed to suppress the installation of libiberty.a; it is provided by
# binutils.
#
if [[ "${XBT_GCC}" == "gcc-4.6.4" ]]; then
	(
	# Use a subshell-- I dun know why...
	cd ../${XBT_GCC}
	sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
	)
	CONFIGURE_LDFLAGS="-lm -lstdc++"
	CONFIGURE_ENABLES="--enable-cloog-backend=isl"
	CONFIGURE_DISABLES="--disable-libquadmath --disable-lto"
	CONFIGURE_WITHS="\
--with-cloog=${XBT_XHOST_DIR}/usr \
--with-gmp=${XBT_XHOST_DIR}/usr \
--with-mpc=${XBT_XHOST_DIR}/usr \
--with-mpfr=${XBT_XHOST_DIR}/usr \
--with-ppl=${XBT_XHOST_DIR}/usr"
	CONFIGURE_WITHOUTS=""
fi

# Configure GCC for using only /lib and NOT /lib64 for x86_64.
#
if [[ "${XBT_LINUX_ARCH}" == "x86_64" ]]; then
	(
	cd ../${XBT_GCC}
	# Change GCC to use /lib for 64-bit stuff, not /lib64
	sed -e 's|/lib64/ld-linux|/lib/ld-linux|' -i gcc/config/i386/linux64.h
	sed -e 's| ../lib64 | ../lib |'           -i gcc/config/i386/t-linux64
	# On x86_64, unsetting the multilib spec for GCC ensures that it won't
	# attempt to link against libraries on the host.
	if [[ "${XBT_GCC}" == "gcc-4.6.4" ]]; then
		for file in $(find gcc/config -name t-linux64) ; do
			sed -e '/MULTILIB_OSDIRNAMES/,+1d' -i ${file}
		done
	else
		for file in $(find gcc/config -name t-linux64) ; do
			sed -e '/MULTILIB_OSDIRNAMES/d' -i ${file}
		done
	fi
	)
fi

ENABLE__CXA_ATEXIT=""
ENABLE_LANGUAGES="--enable-languages=c"
if [[ "${XBT_C_PLUS_PLUS}" == "yes" ]]; then
	ENABLE__CXA_ATEXIT="--enable-__cxa_atexit"
	ENABLE_LANGUAGES="--enable-languages=c,c++"
fi

ENABLE_THREADS="--enable-threads=no"
[[ "${XBT_THREAD_MODEL}" == "nptl" ]] && ENABLE_THREADS="--enable-threads=posix"

# Configure GCC for building.
#
# -enable-shared --enable-threads=posix --enable-__cxa_atexit:
# These commands are required to build the C++ libraries to published standards.
#
# --enable-clocale=gnu:
# This command is a failsafe for incomplete locale data.
#
echo "#: *********************************************************************"
echo "#: XBT_CONFIG"
echo "#: *********************************************************************"
LDFLAGS="${CONFIGURE_LDFLAGS}" \
../${XBT_GCC}/configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--target=${XBT_TARGET} \
	--prefix=${XBT_XHOST_DIR}/usr \
	--infodir=${XBT_XHOST_DIR}/usr/share/info \
	--mandir=${XBT_XHOST_DIR}/usr/share/man \
	${ENABLE_LANGUAGES} \
	--enable-c99 \
	--enable-clocale=gnu \
	--enable-long-long \
	--enable-shared \
	${ENABLE_THREADS} \
	${ENABLE__CXA_ATEXIT} \
	${CONFIGURE_ENABLES} \
	--disable-libada \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--disable-multilib \
	${CONFIGURE_DISABLES} \
	--with-headers=${XBT_XTARG_DIR}/usr/include \
	--with-sysroot=${XBT_XTARG_DIR} \
	${CONFIGURE_WITHS} \
	${CONFIGURE_WITHOUTS} || exit 1

xbt_debug_break "configured ${XBT_GCC} for stage 3" >&${CONSOLE_FD}

# Build GCC.
#
echo "#: *********************************************************************"
echo "#: XBT_MAKE"
echo "#: *********************************************************************"
#njobs=$((${ncpus} + 1))
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make || exit 1
#PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make -j ${njobs} || exit 1
#unset njobs

xbt_debug_break "maked ${XBT_GCC} for stage 3" >&${CONSOLE_FD}

# Install GCC.
#
echo "#: *********************************************************************"
echo "#: XBT_INSTALL"
echo "#: *********************************************************************"
xbt_files_timestamp
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make install || exit 1
ln -s "${XBT_TARGET}-gcc" "${XBT_XHOST_DIR}/usr/bin/${XBT_TARGET}-cc"

echo "#: *********************************************************************"
echo "#: XBT_FILES"
echo "#: *********************************************************************"
xbt_files_find # Put the list of installed files in the log file.

xbt_debug_break "installed ${XBT_GCC} for stage 3" >&${CONSOLE_FD}

# Move out and clean up.
#
cd ..
rm -rf "build-gcc"
rm -rf "${XBT_GCC}"

echo "done [${XBT_GCC} is complete]" >&${CONSOLE_FD}

return 0

}


# end of file

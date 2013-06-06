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

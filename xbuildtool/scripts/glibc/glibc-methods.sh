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
#	This script builds the cross-development GLIBC.
#
# CHANGE LOG
#
#	03jun13	drj	Reorganize xbuildtool files.  Scrub architecture.
#	05dec12	drj	Added the XBT_*_EXT variables.
#	24mar12	drj	Added fix for mixed implicit and normal rules.
#	19feb12	drj	Added text manifest of tool chain components.
#	11feb12	drj	Bash assault; nicked from Yann E. MORIN
#	11feb12	drj	Get features.h into ${INCLDIR}/
#	31jan11	drj	Removed intermediate lib/crt[1in].o
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
#      glibc-versions.sh
#
# Sets:
#     XBT_LIBC
#     XBT_LIBC_EXT
#     XBT_LIBC_MD5SUM
#     XBT_LIBC_URL
#     XBT_LIBC_P
#     XBT_LIBC_P_EXT
#     XBT_LIBC_P_MD5SUM
#     XBT_LIBC_P_URL

declare XBT_LIBC=""
declare XBT_LIBC_EXT=""
declare XBT_LIBC_MD5SUM=""
declare XBT_LIBC_URL=""

declare XBT_LIBC_P=""
declare XBT_LIBC_P_EXT=""
declare XBT_LIBC_P_MD5SUM=""
declare XBT_LIBC_P_URL=""

libc_resolve_name() {

source ${XBT_SCRIPT_DIR}/glibc/glibc-versions.sh

local -r  glibcNameVer=${1}    # delare read-only
local -ir rcount=${#_GLIBC[@]} # delare integer, read-only
local -i  i=0                  # delare integer

for (( i=0 ; i<${rcount} ; i++ )); do
	if [[ "${glibcNameVer}" == "${_GLIBC[$i]}" ]]; then
		XBT_LIBC="${_GLIBC[$i]}"
		XBT_LIBC_EXT="${_GLIBC_EXT[$i]}"
		XBT_LIBC_MD5SUM="${_GLIBC_MD5SUM[$i]}"
		XBT_LIBC_URL="${_GLIBC_URL[$i]}"
		XBT_LIBC_P="${_GLIBC_P[$i]}"
		XBT_LIBC_P_EXT="${_GLIBC_P_EXT[$i]}"
		XBT_LIBC_P_MD5SUM="${_GLIBC_P_MD5SUM[$i]}"
		XBT_LIBC_P_URL="${_GLIBC_P_URL[$i]}"
		break # for loop
	fi
done

unset _GLIBC
unset _GLIBC_EXT
unset _GLIBC_MD5SUM
unset _GLIBC_URL

unset _GLIBC_P
unset _GLIBC_P_EXT
unset _GLIBC_P_MD5SUM
unset _GLIBC_P_URL

if [[ -z "${XBT_LIBC}" ]]; then
	echo "E> Cannot resolve \"${glibcNameVer}\""
	return 1
fi

return 0

}


# end of file

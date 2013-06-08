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


# *************************************************************************** #
#                                                                             #
# C A L L B A C K   P R O C E D U R E S                                       #
#                                                                             #
# *************************************************************************** #


# These procedures are expected to be called from the package-specific building
# procedures in the binutils/ gcc/ glibc/ linux/ uClibc/ directories, sort of
# like call-back functions.  Some of these procedures have standard output
# redirected to a log file.
#
# These procedures also are available to the _build-toolchain.sh script.


# *****************************************************************************
# Print No More Than 40 Dots
# *****************************************************************************

# Standard output is expected NOT to be redirected to a log file.

xbt_print_dots_40() {

set +e ; # Let the while loop fail without exiting this script.
local -i i=$((40 - ${1})) # declare integer
while [[ ${i} -gt 0 ]]; do
	echo -n "."
	i=$((${i} - 1))
done
set -e ; # All done with while loop; fail enabled.

}


# *****************************************************************************
# xbt_debug_break
# *****************************************************************************

# This wacky procedure pauses between build steps; it may read input and change
# the stepping behavior based upon the user input.
#
# This procedure must be given an argument; this argument is displayed to the
# standard output.  An empty argument, "", can be used.
#
# For an empty argument, "", this procedure puts a newline to standard output
# and sets XBT_STEP=yes which starts the stepping behavior, which is weird
# because if stepping is "no" (or unset) then NOTHING HAPPENS.
#
# The value of XBT_STEP is the stepping state.
# XBT_STEP is unset or empty ... there is no stepping and the state of stepping
#                                is not changed while the script is executing
# XBT_STEP is "yes" ............ there is a pause with any non-empty argument
# XBT_STEP is "skp" ............ there is no pause until after an empty argument
#
# The stepping behavior is changed based upon the argument and the user input:
# empty argument, "" ........... stepping in all cases is resumed
# user gives "g" ............... stepping is turned off; no more stepping (go)
# user gives "s" ............... stepping is turned off until empty argument
#
# Standard output is expected NOT to be redirected to a log file.

xbt_debug_break() {

if [[ x"${XBT_STEP:-no}" == x"yes" || x"${XBT_STEP:-no}" == x"skp" ]]; then
	local prompt="${1:0:40}" # No more than 40 characters.
	if [[ -z "${prompt}" ]]; then
		echo ""
		XBT_STEP=yes
	else
		printf "** %40s" "${prompt}"
		if [[ ${XBT_STEP} == "yes" ]]; then
			echo -n " ->"
			read
			[[ "${REPLY}" == "g" ]] && XBT_STEP=no  || true
			[[ "${REPLY}" == "s" ]] && XBT_STEP=skp || true
		else
			echo ""
		fi
	fi
fi

}


# *****************************************************************************
# Get a source package; uncompress and untar it.
# *****************************************************************************

# Usage: xbt_src_get <base_filename> [<secondary_copy_location>]

# This procedure can only get files whose name end in ".tar.gz" or ".tar.bz2".
#
# This procedure is expected to be called from a package-specific building
# procedure in another file whose standard output is being redirected to a log
# file.  Screen output must be directory to ${CONSOLE_FD} and standard output,
# which is going into a log file, should be prefixed with "#: ".
#
# An odd side-affect of this procedure is setting the _name variable; it is
# then name of the retrieved file with no path component in the name.

xbt_src_get() {

echo "#: Finding, uncompressing, untarring ${1}"

local pname="${XBT_SOURCE_DIR}/${1}.tar"
local tname="${1}.tar"
local zname=""

if [[ ! -f "${pname}.gz" && ! -f "${pname}.bz2" ]]; then
	echo "#: Cannot find ${pname}.gz or ${pname}.bz2"
	echo "Cannot find ${pname}.gz or ${pname}.bz2" >&${CONSOLE_FD}
	exit 1
fi
[[ -f "${pname}.gz"  ]] && zname="${tname}.gz"  || true
[[ -f "${pname}.bz2" ]] && zname="${tname}.bz2" || true
echo "#: Using ${XBT_SOURCE_DIR}/${zname}"
cp "${XBT_SOURCE_DIR}/${zname}" .

rm -rf "${1}"

if [[ $# -gt 1 ]]; then
	mkdir -p "$2"
	cp "${zname}" "$2"
	chmod 644 "$2/${zname}"
fi

set +e ; # Let tar fail without exiting this script.
tar -xf "${zname}"
if [[ $? -ne 0 ]]; then
	bunzip2 "${zname}" || gunzip "${zname}"
	tar -xf "${tname}"
fi
set -e ; # All done with tar.

if [[ ! -d ${1} ]]; then
	echo "#: Cannot unzip ${zname}"
	echo "Cannot unzip ${zname}" >&${CONSOLE_FD}
	exit 1
fi

_name="${zname}"

rm -f "${zname}"
rm -f "${tname}"

}


# *****************************************************************************
# Make a Timestamp File
# *****************************************************************************

xbt_files_timestamp() {

rm -rf "INSTALL_STAMP"
touch  "INSTALL_STAMP"
sleep 1 # lame

}


# *****************************************************************************
# Find Files Newer Than Timestamp File; Print Their Names
# *****************************************************************************

xbt_files_find() {

find ${XBT_TARGET_DIR} -newer INSTALL_STAMP ! -type d
rm -rf "INSTALL_STAMP"

}



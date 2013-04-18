#!/bin/bash


# *****************************************************************************
# Only root can do this stuff.
# *****************************************************************************

#if [[ $(id -u) -ne 0 ]]; then
#	echo "E> Only root can do this (scary)." >&2
#	exit 1
#fi
#
#if [[ $(id -g) -ne 0 ]]; then
#	echo "E> Must be in the root group, not the $(id -gn) group." >&2
#	echo "E> Try using 'newgrp - root'." >&2
#	exit 1
#fi


# *****************************************************************************
# Constants
# *****************************************************************************

K_TB=$'\t'
K_NL=$'\n'
K_SP=$' '

MY_LOGFILE="${0%.sh}_$(date '+20%y-%m-%d-%X').log"
MY_TEST_NAME=$(basename "${0%.sh}")
MY_TEST_OK=1
MY_INIT_STAMP=${SECONDS}


# *****************************************************************************
# Set up the shell functions and environment variables.
# *****************************************************************************

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.

export IFS="${K_SP}${K_TB}${K_NL}"
export LC_ALL=POSIX
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

umask 022


# *****************************************************************************
# Always clear the logfile.
# *****************************************************************************

rm -f ${MY_LOGFILE}
>${MY_LOGFILE}

date '+DATE:  %a. %h %d, 20%y' >>${MY_LOGFILE}
date '+TIME:  %r'              >>${MY_LOGFILE}
echo ""                        >>${MY_LOGFILE}


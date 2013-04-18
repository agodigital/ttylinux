#!/bin/bash

# 4.2-01
# All executable and library files should have no unresolved dynamic
# dependencies.  Check the files in
#    1. /bin
#    2. /sbin
#    3. /lib
#    4. /usr/bin
#    5. /usr/sbin
#    6. /usr/lib

# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #

# *****************************************************************************
# Procedure check_ldd
# *****************************************************************************

check_ldd() {

local lddErr=0
local fname=""

cd $1
for fname in *; do
	[[ ! -f ${fname} ]] && continue
	if ldd ${fname} 2>/dev/null | grep "not found" >/dev/null; then
		echo "     ->$1/${fname}"
		lddErr=1
	fi
done

return ${lddErr}

}

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

(check_ldd "/bin")      || stat=1 && true;
(check_ldd "/sbin")     || stat=1 && true;
(check_ldd "/lib")      || stat=1 && true;
(check_ldd "/usr/bin")  || stat=1 && true;
(check_ldd "/usr/sbin") || stat=1 && true;
(check_ldd "/usr/lib")  || stat=1 && true;

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


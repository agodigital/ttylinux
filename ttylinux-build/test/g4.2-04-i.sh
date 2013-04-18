#!/bin/bash

# 4.2-04
# Empty package lists should be reported.

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

echo "=> checking package lists' files ..."
for pname in /usr/share/ttylinux/*; do
	[[ "$(basename ${pname})" == "pkg-basefs-FILES" ]] && continue
	fsize=$(stat -c %s ${pname})
	if [[ ${fsize} -eq 0 ]]; then
		echo "   -> ${pname} [empty]"
		stat=1
	fi
done
echo "   ***** DONE"

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


#!/bin/bash

# 4.2-03
# All files listed in the /usr/share/ttylinux/ package lists should be verified
# to exist.  Missing files should be reported.

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

echo "=> checking package lists' files ..."
for pname in /usr/share/ttylinux/*; do
	[[ "$(basename ${pname})" == "pkg-basefs-FILES" ]] && continue
	for fname in $(<${pname}); do
		if [[ ! -e "/${fname}" ]]; then
			echo "   -> missing /${fname} [${pname}]"
			stat=1
		fi
	done
done
echo "   ***** DONE"

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi



#!/bin/bash

# 4.2-02
# All files in system should be checked first against an exclude-from-test list
# then against the /usr/share/ttylinux/ package lists.  Lost files (files not
# found in any package list) should be reported, and any multiply-owned file
# should be reported with the names of the packages claiming the file.

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0
K_FLIST="/root/fileList"

echo -n "=> making file list (be patient) ... "
rm -f ${K_FLIST}
find / -type f >${K_FLIST}
echo "DONE"

echo -n "=> trimming file list .............. "
set +e # #Exit on command error.
sed -e "/\/$/d"                                           -i ${K_FLIST}
sed -e "/\/dev\//d"                                       -i ${K_FLIST}
sed -e "/\/etc\/.norootfsck/d"                            -i ${K_FLIST}
sed -e "/\/etc\/.first_boot_done/d"                       -i ${K_FLIST}
sed -e "/\/etc\/ld.so.cache/d"                            -i ${K_FLIST}
sed -e "/\/etc\/asound.state/d"                           -i ${K_FLIST}
sed -e "/\/etc\/resolv.conf/d"                            -i ${K_FLIST}
sed -e "/\/etc\/ssh\//d"                                  -i ${K_FLIST}
sed -e "/\/etc\/udev\/rules.d\/70-persistent-cd.rules/d"  -i ${K_FLIST}
sed -e "/\/etc\/udev\/rules.d\/70-persistent-net.rules/d" -i ${K_FLIST}
sed -e "/\/lost+found/d"                                  -i ${K_FLIST}
sed -e "/\/proc\//d"                                      -i ${K_FLIST}
sed -e "/\/root\//d"                                      -i ${K_FLIST}
sed -e "/\/run\/udev\//d"                                 -i ${K_FLIST}
sed -e "/\/sys\//d"                                       -i ${K_FLIST}
sed -e "/\/usr\/share\/ttylinux\//d"                      -i ${K_FLIST}
sed -e "/\/var\/lib\//d"                                  -i ${K_FLIST}
sed -e "/\/var\/lock\//d"                                 -i ${K_FLIST}
sed -e "/\/var\/log\//d"                                  -i ${K_FLIST}
sed -e "/\/var\/run\//d"                                  -i ${K_FLIST}
sed -e "s/\///"                                           -i ${K_FLIST}
set -e # #Do not exit on command error.
echo "DONE"

echo "=> checking package lists against file list (be really patient) ..."
for fname in $(<${K_FLIST}); do
	npkg=0
	for pname in /usr/share/ttylinux/*; do
		grep "^${fname}$" ${pname} >/dev/null && npkg=$((${npkg} + 1))
	done
	case ${npkg} in
		0)	echo "   -> /${fname} [no package]"
			stat=1 ;;
		1)	;;
		*)	echo "   -> /${fname} [multiple]"
			stat=1 ;;
	esac
done
echo "   ***** DONE"

echo "=> removing file list"
rm -f ${K_FLIST}

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


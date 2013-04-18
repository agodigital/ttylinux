#!/bin/bash

# 4.3-08
# Verify ftpd with a binary file.

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

putFile="KISSME"
getFile="MEKISS"
byte=0

# Make a .netrc file.
#
rm --force ~/.netrc
echo "login    anonymous" >>~/.netrc
echo "password anonymous" >>~/.netrc

# Make a test file.
#
rm --force ${TTYLINUX_DIR}/test/${putFile}
rm --force ${TTYLINUX_DIR}/test/${getFile}
for byte in {0..7}{0..7}{0..7}; do
	echo -ne "\\0${byte}" >>${TTYLINUX_DIR}/test/${putFile}
done

# Put the test file.
#
ssh root@${TARGET_IP} "rm -f /home/ftpd/${putFile}"
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "ssh com FAILED"
echo "put ${TTYLINUX_DIR}/test/${putFile} ${putFile}" | ftp -n ${TARGET_IP}
echo "get ${putFile} ${TTYLINUX_DIR}/test/${getFile}" | ftp -n ${TARGET_IP}
echo "del ${putFile}"                                 | ftp -n ${TARGET_IP}
echo "Cleaned target ftpd directory:"
ssh root@${TARGET_IP} "ls -l /home/ftpd"
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "ssh com FAILED"

# Check the test files.
#
if diff ${TTYLINUX_DIR}/test/{${putFile},${getFile}} >/dev/null; then
	echo "file put is file get(ed) ... OK"
else
	echo "ftp is BROKEN -- test *FAILED*"
	stat=1
fi

# Cleanup.
#
rm --force ~/.netrc
rm --force ${TTYLINUX_DIR}/test/${putFile}
rm --force ${TTYLINUX_DIR}/test/${getFile}

unset putFile
unset getFile
unset byte

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


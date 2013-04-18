#!/bin/bash

# 4.3-07
# Verify tftpd with a binary file <f1>:
#    tftp -m binary ${TargetIP} -c put <f1> <f2>
#    tftp -m binary ${TargetIP} -c get <f2> <f3>
#    diff <f1> <f3>

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

putFile="KISSME"
getFile="MEKISS"
byte=0

# Make a test file.
#
rm --force ${TTYLINUX_DIR}/test/${putFile}
rm --force ${TTYLINUX_DIR}/test/${getFile}
for byte in {0..7}{0..7}{0..7}; do
	echo -ne "\\0${byte}" >>${TTYLINUX_DIR}/test/${putFile}
done

# Put the test file.
#
ssh root@${TARGET_IP} "rm -f /home/tftpd/${putFile}"
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "ssh com FAILED"
tftp -m binary ${TARGET_IP} -c put "${TTYLINUX_DIR}/test/${putFile}" ${putFile}
[[ $? -eq 0 ]] && echo "tftp put OK" || echo "tftp put FAILED"

# Get the test file.
#
ssh root@${TARGET_IP} "ls /home/tftpd/${putFile}" >/dev/null
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "Test file not found on target."
tftp -m binary ${TARGET_IP} -c get ${putFile} "${TTYLINUX_DIR}/test/${getFile}"
[[ $? -eq 0 ]] && echo "tftp get OK" || echo "tftp put FAILED"

# Check the test files.
#
if diff ${TTYLINUX_DIR}/test/{${putFile},${getFile}} >/dev/null; then
	echo "file put is file get(ed) ... OK"
else
	echo "tftp is BROKEN -- test *FAILED*"
	stat=1
fi

# Cleanup.
#
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


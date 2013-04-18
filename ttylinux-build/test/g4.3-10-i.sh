#!/bin/bash

# 4.3-10

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

tKeyFile="/etc/ssh/rsa_host_key"
tGetFile="README-problems.txt"
tDstFile="${TEST_USER}@${HOST_IP}:${TTYLINUX_DIR}/test/${tGetFile}"
hDstFile="${TTYLINUX_DIR}/test/${tGetFile}"

REPLY=""
while [[ "${REPLY:0:1}" != "y" ]]; do
	echo "Fix the host to get commands from the ttylinux system under test:"
	echo "     vi ~/.ssh/authorized_keys # ***** Remove ${TARGET_IP}"
	read -p "Host is fixed [y,n] >"
done

# Get the unit under test target public key; this will enable it to SSH and
# SCP test host without needing to use a password.
#
rm --force "${TTYLINUX_DIR}/test/tmpkey"
scp "root@${TARGET_IP}:ssh-host-rsa-key.pub" "${TTYLINUX_DIR}/test/tmpkey"
cat "${TTYLINUX_DIR}/test/tmpkey" >>~/.ssh/authorized_keys
rm --force "${TTYLINUX_DIR}/test/tmpkey"

# Remove any test files then command the target to SCP a copy of the test file
# to the this host.  Notice the name of the file as it is gotten to this host.
#
rm --force "${hDstFile}" "${hDstFile}2"
ssh root@${TARGET_IP} "scp -i ${tKeyFile} ${tGetFile} ${tDstFile}"
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "ssh com FAILED"

# Directly get a copy of the test file via SCP.  Notice the name of the file as
# it is gotten to this test host.
#
scp root@${TARGET_IP}:${tGetFile} ${hDstFile}2

# Check the test files.
#
diff ${hDstFile} ${hDstFile}2 >/dev/null || stat=1

# Remove any test files.
#
rm --force "${hDstFile}" "${hDstFile}2"

REPLY=""
while [[ "${REPLY:0:1}" != "y" ]]; do
	echo "Fix host to NOT get commands from the ttylinux system under test:"
	echo "     vi ~/.ssh/authorized_keys # ***** Remove ${TARGET_IP}"
	read -p "Host is fixed [y,n] >"
done

unset tKeyFile
unset tGetFile
unset tDstFile
unset hDstFile

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


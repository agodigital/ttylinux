#!/bin/bash

# 4.3-09
# Verify FSv2 mounting and NFSv3 mounting.
#    mount -t nfs -o nolock,rw,vers=2 <server>:/home/SharedDocs /mnt/flash
#    mount -t nfs -o nolock,rw,vers=3 <server>:/home/SharedDocs /mnt/flash

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

ldir="/home/SharedDocs"
sdir="${HOST_IP}:${ldir}"
tfname="README-problems.txt"

# Setup access to the shared directory and remove the test file that might be
# in it.
#
echo "sudo chown ${TEST_USER}:${TEST_USER} ${ldir}"
sudo chown ${TEST_USER}:${TEST_USER} ${ldir}
echo "sudo rm --force ${ldir}/${tfname}"
sudo rm --force ${ldir}/${tfname}

# Remove the test file that might be in the test directory.
#
rm --force ${TTYLINUX_DIR}/test/${tfname}

# The firewall may block NFS mounting.
#
REPLY=""
while [[ "${REPLY:0:1}" != "y" ]]; do
	echo "Does your firewall block NFS mounting?"
	read -p "Wait here until firewall is disabled. Continue? [y] >"
done

# Send commands to the target for it to MFS mount using Vers 2 and put the
# test file into the NFS-mounted directory.             ------
# Get the test file directory via SCP into the test directory.
#
ssh root@${TARGET_IP} "mount -t nfs -o nolock,rw,vers=2 ${sdir} /mnt/flash"
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "ssh com FAILED"
ssh root@${TARGET_IP} "cp ${tfname} /mnt/flash"
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "ssh com FAILED"
ssh root@${TARGET_IP} "umount /mnt/flash"
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "ssh com FAILED"
scp "root@${TARGET_IP}:/root/${tfname}" "${TTYLINUX_DIR}/test/${tfname}"
[[ $? -eq 0 ]] && echo "scp com OK"  || echo "scp com FAILED"

# Setup access to the test file in the shared directory; the target should have 
# put the test file there nia NFS mount.
#
echo "sudo chown ${TEST_USER}:${TEST_USER} ${ldir}/${tfname}"
sudo chown ${TEST_USER}:${TEST_USER} ${ldir}/${tfname}

# Compare the test file gotten via NFS target-mounted shared directory with the
# test file gotten via SCP.
#
if diff ${ldir}/${tfname} ${TTYLINUX_DIR}/test/${tfname} >/dev/null; then
	echo "target NFS OK"
else
	echo "target NFS BROKEN -- test *FAILED*"
	stat=1
fi

# Remove the test file from the shared directory and from the test directory.
#
rm --force ${ldir}/${tfname}
rm --force ${TTYLINUX_DIR}/test/${tfname} 

# Send commands to the target for it to MFS mount using Vers 3 and put the
# test file into the NFS-mounted directory.             ------
# Get the test file directory via SCP into the test directory.
#
ssh root@${TARGET_IP} "mount -t nfs -o nolock,rw,vers=3 ${sdir} /mnt/flash"
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "ssh com FAILED"
ssh root@${TARGET_IP} "cp ${tfname} /mnt/flash"
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "ssh com FAILED"
ssh root@${TARGET_IP} "umount /mnt/flash"
[[ $? -eq 0 ]] && echo "ssh com OK"  || echo "ssh com FAILED"
scp "root@${TARGET_IP}:/root/${tfname}" "${TTYLINUX_DIR}/test/${tfname}"
[[ $? -eq 0 ]] && echo "scp com OK"  || echo "scp com FAILED"

# Setup access to the test file in the shared directory; the target should have 
# put the test file there nia NFS mount.
#
echo "sudo chown ${TEST_USER}:${TEST_USER} ${ldir}/${tfname}"
sudo chown ${TEST_USER}:${TEST_USER} ${ldir}/${tfname}

# Compare the test file gotten via NFS target-mounted shared directory with the
# test file gotten via SCP.
#
if diff ${ldir}/${tfname} ${TTYLINUX_DIR}/test/${tfname} >/dev/null; then
	echo "target NFS OK"
else
	echo "target NFS BROKEN -- test *FAILED*"
	stat=1
fi

# Remove the test file from the shared directory and from the test directory.
#
rm --force ${ldir}/${tfname}
rm --force ${TTYLINUX_DIR}/test/${tfname} 

unset hostip
unset ldir
unset sdir
unset tfname

# The firewall may block NFS mounting.
#
REPLY=""
while [[ "${REPLY:0:1}" != "y" ]]; do
	echo "Re-enable your firewall."
	read -p "Wait here until firewall is Enabled. Continue? [y] >"
done

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


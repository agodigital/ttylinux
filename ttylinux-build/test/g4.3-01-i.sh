#!/bin/bash

# 4.3-01
# Verify the file ownership, permission, and contents of /etc/ttylinux-build
# and /etc/ttylinux-target.


# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

ssh root@${TARGET_IP} 'ls -l /etc/ttylinux-*'
echo "/etc/ttylinux-build"
ssh root@${TARGET_IP} 'cat /etc/ttylinux-build'
echo "/etc/ttylinux-target"
ssh root@${TARGET_IP} 'cat /etc/ttylinux-target'

pbits=$(ssh root@${TARGET_IP} 'stat -c %a /etc/ttylinux-build')
cdata=$(ssh root@${TARGET_IP} 'cat /etc/ttylinux-build')
[[ "${pbits}" == "644" ]]    || stat=1
[[ "${cdata}" == "x86_64" ]] || stat=1
unset pbits
unset cdata

pbits=$(ssh root@${TARGET_IP} 'stat -c %a /etc/ttylinux-target')
cdata=$(ssh root@${TARGET_IP} 'cat /etc/ttylinux-target')
[[ "${pbits}" == "644" ]]           || stat=1
[[ "${cdata}" == "${TARGET_TAG}" ]] || stat=1
unset pbits
unset cdata

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


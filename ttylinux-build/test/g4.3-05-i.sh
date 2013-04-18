#!/bin/bash

# 4.3-05
# Verify /proc/cmdline items: ttylinux-cdrom.


# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

cmdline=$(ssh root@${TARGET_IP} 'cat /proc/cmdline')

echo "cat /proc/cmdline"
echo "${cmdline}"

echo "${cmdline}" | grep "ttylinux-cdrom" >/dev/null || {
	stat=1
	echo "ERROR* check ttylinux-cdrom"
}

echo "${cmdline}" | grep "enet" >/dev/null || {
	stat=1
	echo "ERROR* check enet"
}

echo "${cmdline}" | grep "host=yuki.ttylinux.net" >/dev/null || {
	stat=1
	echo "ERROR* check host=yuki.ttylinux.net"
}

echo "${cmdline}" | grep "tz=MST" >/dev/null || {
	stat=1
	echo "ERROR* check tz=MST"
}

echo "${cmdline}" | grep "hwclock=local" >/dev/null || {
	stat=1
	echo "ERROR* check hwclock=local"
}

unset cmdline

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


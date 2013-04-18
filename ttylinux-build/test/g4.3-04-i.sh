#!/bin/bash

# 4.3-04
# Verify this process status:
#    sbin/klogd -c 2
#    sbin/syslogd -s 128
#    usr/sbin/dropbear
#    usr/sbin/inetd
#    usr/sbin/crond -l 0 -c /var/spool/cron/crontabs

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

targetps=$(ssh root@${TARGET_IP} 'ps')

echo "Process Status:"

psline1='/sbin/klogd -c 2'
psline2='/sbin/syslogd -s 128'
psline3='/usr/sbin/dropbear'
psline4='/usr/sbin/inetd'
psline5='/usr/sbin/crond -l 0 -c /var/spool/cron/crontabs'

echo "${targetps}" | grep "klogd"    || true
echo "${targetps}" | grep "syslogd"  || true
echo "${targetps}" | grep "dropbear" || true
echo "${targetps}" | grep "inetd"    || true
echo "${targetps}" | grep "crond"    || true

echo "${targetps}" | grep "${psline1}" >/dev/null || echo "ERROR* klogd"
echo "${targetps}" | grep "${psline2}" >/dev/null || echo "ERROR* syslogd"
echo "${targetps}" | grep "${psline3}" >/dev/null || echo "ERROR* dropbear"
echo "${targetps}" | grep "${psline4}" >/dev/null || echo "ERROR* inetd"
echo "${targetps}" | grep "${psline5}" >/dev/null || echo "ERROR* crond"

echo "${targetps}" | grep "${psline1}" >/dev/null || stat=1
echo "${targetps}" | grep "${psline2}" >/dev/null || stat=1
echo "${targetps}" | grep "${psline3}" >/dev/null || stat=1
echo "${targetps}" | grep "${psline4}" >/dev/null || stat=1
echo "${targetps}" | grep "${psline5}" >/dev/null || stat=1

unset targetps
unset psline1
unset psline2
unset psline3
unset psline4
unset psline5

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


#!/bin/bash

# 4.3-03
# Verify the permissions, ownerships, and contents of the /etc/ssh files, and
# for the /root/ssh-host-???-key.pub files.

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

ssh root@${TARGET_IP} 'ls -la /etc/ssh'

pbits[1]=$(ssh root@${TARGET_IP} 'stat -c %a /etc/ssh/dss_host_key')
pbits[2]=$(ssh root@${TARGET_IP} 'stat -c %a /etc/ssh/dss_host_key.pub')
pbits[3]=$(ssh root@${TARGET_IP} 'stat -c %a /etc/ssh/rsa_host_key')
pbits[4]=$(ssh root@${TARGET_IP} 'stat -c %a /etc/ssh/rsa_host_key.pub')

group[1]=$(ssh root@${TARGET_IP} 'stat -c %g /etc/ssh/dss_host_key')
group[2]=$(ssh root@${TARGET_IP} 'stat -c %g /etc/ssh/dss_host_key.pub')
group[3]=$(ssh root@${TARGET_IP} 'stat -c %g /etc/ssh/rsa_host_key')
group[4]=$(ssh root@${TARGET_IP} 'stat -c %g /etc/ssh/rsa_host_key.pub')

owner[1]=$(ssh root@${TARGET_IP} 'stat -c %u /etc/ssh/dss_host_key')
owner[2]=$(ssh root@${TARGET_IP} 'stat -c %u /etc/ssh/dss_host_key.pub')
owner[3]=$(ssh root@${TARGET_IP} 'stat -c %u /etc/ssh/rsa_host_key')
owner[4]=$(ssh root@${TARGET_IP} 'stat -c %u /etc/ssh/rsa_host_key.pub')

[[ "${pbits[1]}" == "600" ]] || stat=1
[[ "${pbits[2]}" == "644" ]] || stat=1
[[ "${pbits[3]}" == "600" ]] || stat=1
[[ "${pbits[4]}" == "644" ]] || stat=1

[[ ${group[1]} -eq 0 ]] || stat=1
[[ ${group[2]} -eq 0 ]] || stat=1
[[ ${group[3]} -eq 0 ]] || stat=1
[[ ${group[4]} -eq 0 ]] || stat=1

[[ ${owner[1]} -eq 0 ]] || stat=1
[[ ${owner[2]} -eq 0 ]] || stat=1
[[ ${owner[3]} -eq 0 ]] || stat=1
[[ ${owner[4]} -eq 0 ]] || stat=1

ssh root@${TARGET_IP} 'ls -la /root/ssh-host-???-key.pub'

pbits[1]=$(ssh root@${TARGET_IP} 'stat -c %a /root/ssh-host-dss-key.pub')
group[1]=$(ssh root@${TARGET_IP} 'stat -c %g /root/ssh-host-dss-key.pub')
owner[1]=$(ssh root@${TARGET_IP} 'stat -c %u /root/ssh-host-dss-key.pub')

pbits[2]=$(ssh root@${TARGET_IP} 'stat -c %a /root/ssh-host-rsa-key.pub')
group[2]=$(ssh root@${TARGET_IP} 'stat -c %g /root/ssh-host-rsa-key.pub')
owner[2]=$(ssh root@${TARGET_IP} 'stat -c %u /root/ssh-host-rsa-key.pub')

[[ "${pbits[1]}" == "644" ]] || stat=1
[[ "${pbits[2]}" == "644" ]] || stat=1
[[  ${group[1]} -eq 0 ]] || stat=1
[[  ${group[2]} -eq 0 ]] || stat=1
[[  ${owner[1]} -eq 0 ]] || stat=1
[[  ${owner[2]} -eq 0 ]] || stat=1

unset pbits[1]
unset pbits[2]
unset pbits[3]
unset pbits[4]

unset group[1]
unset group[2]
unset group[3]
unset group[4]

unset owner[1]
unset owner[2]
unset owner[3]
unset owner[4]

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


#!/bin/bash

# 4.3-03
# Verify the contents of the /etc/HOSTNAME file and the output of the
# "hostname" and "hostname -f" commands.  Verify the FQDN is in the
# /etc/hosts file.


# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

etcHostName=$(ssh root@${TARGET_IP} 'cat /etc/HOSTNAME')
hostName=$(ssh root@${TARGET_IP} 'hostname')
hostNameF=$(ssh root@${TARGET_IP} 'hostname -f')

echo "/etc/HOSTNAME => ${etcHostName}"
echo "hostname      => ${hostName}"
echo "hostname -f   => ${hostNameF}"

[[ "${etcHostName}" != "yuki.ttylinux.net" ]] && stat=1
[[ "${hostName}"    != "yuki"              ]] && stat=1
[[ "${hostNameF}"   != "yuki.ttylinux.net" ]] && stat=1

unset etcHostName
unset hostName
unset hostNameF

if [[ ${stat} -eq 0 ]]; then
        echo "***** PASS"
else
        echo "***** FAIL"
fi


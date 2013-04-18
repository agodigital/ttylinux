#!/bin/bash


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# Procedure target_startup
# *****************************************************************************

target_startup() {

echo ""
echo "Boot the ttylinux system under test with these boot parameters:"
echo "     enet"
echo ""

REPLY=""
while [[ "${REPLY:0:1}" != "y" ]]; do
	read -p "Enter IP Address of ttylinux system under test >"
	TARGET_IP=${REPLY}
	read -p "IP Address \"${TARGET_IP}\" is right? [y,n] >"
done

}


# *****************************************************************************
# Procedure host_setup
# *****************************************************************************

host_setup() {

echo ""
REPLY=""
while [[ "${REPLY:0:1}" != "y" ]]; do
	echo "Fix the host to command the ttylinux system under test:"
	echo "     vi ~/.ssh/known_hosts # ***** Remove ${TARGET_IP}"
	echo "     ssh-copy-id -i ~/.ssh/id_rsa.pub root@${TARGET_IP}"
	echo "     ssh-add"
	read -p "Host is fixed [y,n] >"
done
echo ""

}


# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# Set up the shell functions and environment variables.
# *****************************************************************************

source "test/_test-init.sh"
source "test/_test-conf.sh"


# *****************************************************************************
# Main Program
# *****************************************************************************

target_startup
host_setup

tProg[1]="g4.2-01-i.sh"  ; tStat[1]=1
tProg[2]="g4.2-02-i.sh"  ; tStat[2]=1
tProg[3]="g4.2-03-i.sh"  ; tStat[3]=1
tProg[4]="g4.2-04-i.sh"  ; tStat[4]=1
tProg[5]="g4.2-05-i.sh"  ; tStat[5]=1

for ((i=1 ; $i<=5 ; i++)); do
	echo "=> Copying ${tProg[$i]}"
	scp ${TTYLINUX_DIR}/test/${tProg[$i]} root@${TARGET_IP}:${tProg[$i]}
	echo "=> Running ${tProg[$i]}"
	stdOutStr=$(ssh root@${TARGET_IP} ./${tProg[$i]})
	echo "${stdOutStr}"
	echo ""
	statStr=$(echo "${stdOutStr}" | tail -1)
	[[ "${statStr}" == "***** PASS" ]] && tStat[$i]=0
	[[ "${statStr}" == "***** FAIL" ]] && tStat[$i]=1
	[[ ${tStat[$i]} -eq 1 ]] && MY_TEST_OK=0 # ***** FAILURE
done

echo "Test Summary"
for ((i=1 ; $i<=5 ; i++)); do
	echo -n "${tProg[$i]} ..... "
	[[ ${tStat[$i]} -eq 0 ]] && echo "pass"
	[[ ${tStat[$i]} -eq 1 ]] && echo "FAIL"
done
echo ""


# *****************************************************************************
# Exit OK
# *****************************************************************************

source "test/_test-done.sh"

exit 0

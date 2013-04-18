#!/bin/bash

# 4.3-06
# Verify alsa with a remote calls.
#    aplay /usr/share/sounds/alsa/Front_Right.wav
#    aplay /usr/share/sounds/alsa/Rear_Center.wav
#    aplay /usr/share/sounds/alsa/Side_Left.wav

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

if [[ ${TTYLINUX_PLATFORM} == "beagle_bone" ||
      ${TTYLINUX_PLATFORM} == "pc_i486"     ||
      ${TTYLINUX_PLATFORM} == "wrtu54g_tm" ]]; then
	echo "=> System has no ALSA"
	echo "***** NA"
	return
fi

REPLY=""
while [[ "${REPLY:0:1}" != "y" && "${REPLY:0:1}" != "n" ]]; do
	ssh root@${TARGET_IP} 'aplay /usr/share/sounds/alsa/Front_Right.wav'
	read -p "Do you here \"Front Right\"\? [y,n] >"
done
[[ "${REPLY:0:1}" == "n" ]] && stat=1

REPLY=""
while [[ "${REPLY:0:1}" != "y" && "${REPLY:0:1}" != "n" ]]; do
	ssh root@${TARGET_IP} 'aplay /usr/share/sounds/alsa/Rear_Center.wav'
	read -p "Do you here \"Rear Center\"\? [y,n] >"
done
[[ "${REPLY:0:1}" == "n" ]] && stat=1

REPLY=""
while [[ "${REPLY:0:1}" != "y" && "${REPLY:0:1}" != "n" ]]; do
	ssh root@${TARGET_IP} 'aplay /usr/share/sounds/alsa/Side_Left.wav'
	read -p "Do you here \"Side Left\"\? [y,n] >"
done
[[ "${REPLY:0:1}" == "n" ]] && stat=1

if [[ ${stat} -eq 0 ]]; then
	echo "***** PASS"
else
	echo "***** FAIL"
fi


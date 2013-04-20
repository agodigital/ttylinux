#!/bin/bash

TTYLINUX_DIR="$(pwd)"

TTYLINUX_NAME="ocelot"
TTYLINUX_VERSION=16.0

TTYLINUX_PLATFORM="beagle_bone" ; TTYLINUX_CPU="armv7"
TTYLINUX_PLATFORM="wrtu54g_tm"  ; TTYLINUX_CPU="mipsel"
TTYLINUX_PLATFORM="mac_g4"      ; TTYLINUX_CPU="powerpc"
TTYLINUX_PLATFORM="pc_x86_64"   ; TTYLINUX_CPU="x86_64"
TTYLINUX_PLATFORM="pc_i486"     ; TTYLINUX_CPU="i486"
TTYLINUX_PLATFORM="pc_i686"     ; TTYLINUX_CPU="i686"

_ip="$(hostname -I)"
HOST_IP="${_ip// }"
unset _ip

TARGET_IP="192.168.0.10"
TARGET_TAG="${TTYLINUX_VERSION}-${TTYLINUX_CPU}-${TTYLINUX_PLATFORM}"
TEST_USER="djerome"

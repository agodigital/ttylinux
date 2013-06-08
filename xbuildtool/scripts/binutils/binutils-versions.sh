#!/bin/bash

declare -a _BINUTILS
declare -a _BINUTILS_EXT
declare -a _BINUTILS_MD5SUM
declare -a _BINUTILS_URL

_BINUTILS[0]="binutils-2.19.1a" ; _BINUTILS_EXT[0]=".tar.bz2"
_BINUTILS[1]="binutils-2.20.1a" ; _BINUTILS_EXT[1]=".tar.bz2"
_BINUTILS[2]="binutils-2.23.2"  ; _BINUTILS_EXT[2]=".tar.bz2"

_BINUTILS_MD5SUM[0]="17a52219dee5a76c1a9d9b0bfd337d66"
_BINUTILS_MD5SUM[1]="ee2d3e996e9a2d669808713360fa96f8"
_BINUTILS_MD5SUM[2]="4f8fa651e35ef262edc01d60fb45702e"

_BINUTILS_URL[0]="ftp://ftp.gnu.org/gnu/binutils http://ftp.gnu.org/gnu/binutils ftp://sourceware.org/pub/binutils/releases/"
_BINUTILS_URL[1]="ftp://ftp.gnu.org/gnu/binutils http://ftp.gnu.org/gnu/binutils ftp://sourceware.org/pub/binutils/releases/"
_BINUTILS_URL[2]="ftp://ftp.gnu.org/gnu/binutils http://ftp.gnu.org/gnu/binutils ftp://sourceware.org/pub/binutils/releases/"

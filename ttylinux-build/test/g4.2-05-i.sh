#!/bin/bash

# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #

stat=0

# Check if this ttylinux system is supposed to support Gcc:
#
#    platform           Has Gcc
#    --------           -------
#    beagle_bone ...... yes
#    mac_g4 ........... yes
#    pc_i486 .......... no
#    pc_i686 .......... yes
#    pc_x86_64 ........ yes
#    wrtu54g_tm ....... no

if [[ ! -f /etc/ttylinux-target ]]; then
	echo "No /etc/ttylinux-target file, you hoser."
	echo "***** FAIL"
	exit 0
fi

platform=$(</etc/ttylinux-target)
if [[ "${platform##*-}" == "pc_i486" ||
      "${platform##*-}" == "wrtu54g_tm" ]]; then
	echo "=> System has no GCC (nothing to fail this test)"
	echo "***** PASS"
	exit 0
fi

cfile="g4.2-05-i.c"
ofile="g4.2-05-i.o"
xfile="g4.2-05-i"
mfile="g4.2-05-i.rules"
lfile="g4.2-05-i.log"
tfile="g4.2-05-i.txt"

rm -f ${cfile} ${mfile} ${ofile} ${xfile} ${lfile} ${tfile}
touch ${cfile} ${mfile}

echo "2 Hello" >${tfile}

echo "#include <stdio.h>"                             >>${cfile}
echo "int main (int argc, char* argv[])"              >>${cfile}
echo "   {"                                           >>${cfile}
echo "   return printf (\"%d %s\n\", argc, argv[1]);" >>${cfile}
echo "   }"                                           >>${cfile}

echo "CC	= gcc"                >>${mfile}
echo "${xfile}:	${ofile}"             >>${mfile}
echo "	gcc -o ${xfile} ${ofile} -lc" >>${mfile}

make -f ${mfile}

# This program returns the number of character printed, which is 8 for the
#  output "2 Hello\n".
#
./${xfile} Hello >${lfile}
[[ $? -eq 8 ]] || stat=1
echo "\$ ./${xfile} Hello"
echo "$(<${lfile})"

# Check the program output against the expected output.
#
diff ${lfile} ${tfile} || stat=1

rm -f ${cfile} ${mfile} ${ofile} ${xfile} ${lfile} ${tfile}

if [[ ${stat} -eq 0 ]]; then
        echo "***** PASS"
else
        echo "***** FAIL"
fi


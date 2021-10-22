#!/bin/sh
set -x -e

 source ../versions/build.ver
 source ./Module_CCPA_file

 export LIBS="${W3NCO_LIB4} ${BACIO_LIB4}"
 export FC=ftn
 export CPP=icpc
 export FFLAGS="-assume byterecl -convert big_endian -g -traceback"

for dir in *.fd; do
 cd $dir
 make -f Makefile
 cd ..
done

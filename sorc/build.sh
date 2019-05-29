#!/bin/sh
set -x -e
 export LIBDIR=/gpfs/dell1/nco/ops/nwprod/lib/w3nco/v2.0.6/ips/18.0.1
 export LIBS="${W3NCO_LIB4} ${BACIO_LIB4}"
 export FC=ifort
 export CPP=icpc
 export FFLAGS="-assume byterecl -convert big_endian -g -traceback"

for dir in *.fd; do
 cd $dir
 make -f Makefile
 cd ..
done

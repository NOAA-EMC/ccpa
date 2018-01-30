####!/bin/sh
#!/bin/bash
############################################################
#HISTORY:
#2008:       Scripts available through the work of Mike Charles
#03/24/2010: Script slightly modified by Dingchen Hou for CCPA initial implementation
#06/30/2015: Script slightly modified by Yan Luo for adding 2.5KM NDGD grid
#09/26/2017: Script slightly modified by Yan Luo for changing 0.5 degree grid
############################################################

set -x 

# Check that user has provided file(s) to process
if [ $# -lt 1 ]; then
   echo Usage: copygb_pcp interp res filename
   echo res: grid for downscaling 5km,15km,4thd=025d,8thd=0125d,hrap,ndfd
   echo interp  type of interpolation      0,1,2,3
   echo filename =filename of grib file without .grb
   exit
fi

interp=$1
res=$2
filename=$3

# Settings
OUT='.'

# Set grid specifications
case $res in

 1p0) grid="3";;
 0p5) grid="4";;
#0p5) grid="255 0 720 361 -90000 000000 128 90000 359500 500 500 64";; old version
 0p25) grid="255 0 232 112 25125 235125 128 52875 292875 250 250 64";;
 0p125) grid="110 0 464 224 250625 2350625 128 529375 2929375 125 125 64";;
 8thd) grid="255 0 464 224 25125 235125 128 53000 293000 125 125 64";;
 110) grid="110 0 464 224 250625 2350625 128 529375 2929375 125 125 64";;
 cpc_8thd) grid="255 0 601 241 20000 230000 128 50000 305000 125 125 64";;

 240) grid="240 5 1121 881 23098 -119036 8 -105000 4762 4762 0 64";;
 tish) grid="240 5 1121 881 23098 -119036 8 -105000 4762 4762 0 64";;
#hrap) grid="255 5 1121 881 23098 -119036 8 -105000 4762 4762 0 64";; MC defines
 ylin) grid="255 5 1121 881 23117 -119023 8 -105000 4763 4763 0 64";;
 hrap) grid="255 5 1121 881 23117 -119023 8 -105000 4763 4763 0 64";; 

 197) grid="197 3 1073 689 20192 238446 8 265000 5079 5079 0 64 25000 25000 0 0 0";;
 ndfd) grid="197 3 1073 689 20192 238446 8 265000 5079 5079 0 64 25000 25000 0 0 0";;
 ndgd5p0) grid="255 3 1073 689 20192 238446 8 265000 5079 5079 0 64 25000 25000 0 0 0";;
 rtma) grid="255 3 1073 689 20191 238445 8 265000 5079 5079 0 64 25000 25000 0 0 0";;
 ndgd2p5) grid="255 3 2145 1377 20192 238446 8 265000 2539 2539 0 64 25000 25000 -8364400 0 0";;

esac

echo using grid specification:  $grid

# Copy a temporary namelist that will keep the precision
cat  <<EOF > namelist.temp
&NLCOPYGB
EOF

set +x

((i=1))
while [ $i -lt 256 ]
do
 echo "NBS("$i")=16," >> namelist.temp
 ((i=i+1))
done
echo "/" >> namelist.temp

set -x

infile=$filename.grb
outfile=${filename}_${res}.grb
echo Interpolating $infile to $outfile
$COPYGB -N namelist.temp -i"$interp" -g"$grid" -x $infile $OUT/$outfile 
if [ -s ${filename}_${res}.grb ]; then
  echo Interpolation Done!!!
else
  export err=9; err_chk
fi

# Delete temporary namelist
rm -f namelist.temp

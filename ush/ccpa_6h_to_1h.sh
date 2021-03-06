#####!/bin/sh
#!/bin/bash
echo $#

############################################################
#HISTORY:
#09/18/2017: Initial script created by Yan Luo
#09/26/2017: Script modified by Yan Luo for using Stage IV hourly data only 
#01/28/2020: Script modified by Yan Luo for using Stage IV GRIB2 input files
############################################################
#----------------------------------------------------------
# Begginning date and ending hour
if (( $# > 0 )); then
  curdate=$1
  hour=$2
else
  echo 'argument(s) required yyyymmdd hh'
  exit
fi
datnext=`$NDATE +24 $curdate\00 | cut -c1-8`
#
set -x

  case $hour in 

   18) t1=12;ymd=$curdate;datedir=$curdate;h0_6="13 14 15 16 17 18";;
   00) t1=18;ymd=$curdate;datedir=$datnext;h0_6="19 20 21 22 23 00";;
   06) t1=00;ymd=$datnext;datedir=$datnext;h0_6="01 02 03 04 05 06";;
   12) t1=06;ymd=$datnext;datedir=$datnext;h0_6="07 08 09 10 11 12"

  esac

yyyy=` echo $ymd | cut -c1-4 ` 
mm=` echo $ymd | cut -c5-6 ` 
dd=` echo $ymd | cut -c7-8 ` 

ccpa_6hr=$COMOUT.$datedir/$hour

temp_dir=$DATA/ccpa_${datedir}${hour}_01h
if [ -s $temp_dir ]; then
 echo $temp_dir already exists!
 rm -f $temp_dir/*
else
 mkdir -p $temp_dir
 echo $temp_dir is created!
fi

cd $temp_dir

#------------------------------------------------------
# Fetch 1-hourly Stage IV RFC precip file
#

   Num=0
  for HH in ${h0_6} 
  do
   (( Num=Num+1 ))
   if [ $HH == 00 ]; then
    if [ -s $COMINpcpanl.$datnext/st4_conus.${datnext}${HH}.01h.grb2 ]; then
     cp -p  $COMINpcpanl.$datnext/st4_conus.${datnext}${HH}.01h.grb2 $temp_dir
     $CNVGRIB -g21  $temp_dir/st4_conus.${datnext}${HH}.01h.grb2 $temp_dir/ST4.${datnext}${HH}.01h
     cp -p  $temp_dir/ST4.${datnext}${HH}.01h rfc_orig_${Num}.grb   #1
    else
     echo $COMINpcpanl.$datnext/st4_conus.${datnext}${HH}.01h.grb2 does not exist  >>$DATA/warning
     exit
    fi
   else
   if [ -s $COMINpcpanl.$yyyy$mm$dd/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2 ]; then
    cp -p  $COMINpcpanl.$yyyy$mm$dd/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2 $temp_dir
    $CNVGRIB -g21  $temp_dir/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2 $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h
    cp -p  $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h rfc_orig_${Num}.grb   #1
   else
    echo $COMINpcpanl.$yyyy$mm$dd/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2 does not exist  >>$DATA/warning
    exit
    fi
   fi
  done

#------------------------------------------------------
# Disaggregate 6-hourly CCPA into hourly based on hourly
# Stage IV accumulation ratios 
#
# Split  6-hourly CCPA into hourly CCPA (Fortran)

  if eval test -s $ccpa_6hr/ccpa.t${hour}z.06h.hrap.conus
  then
  cp $ccpa_6hr/ccpa.t${hour}z.06h.hrap.conus $temp_dir/rfc_scaled_downscaled.grb
  echo Disaggregating into hourly amounts...                              #2     
  $EXECccpa/ccpa_6h_to_1h ${ymd}${t1}0001 ${ymd}${t1}0001  >> $pgmout 2>errfile             
  export err=$?; err_chk
  echo Disaggregation done
  else
   echo $ccpa_6hr/ccpa.t${hour}z.06h.hrap.conus does not exist  >>$DATA/warning
   exit
  fi

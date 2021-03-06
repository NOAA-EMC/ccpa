#####!/bin/sh
#!/bin/bash
echo $#

############################################################
#HISTORY:
#02/18/2011: Initial script created by Yan Luo
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

   18) t1=12;t2=15;ymd=$curdate;datedir=$curdate;h0_3="13 14 15";h3=15;h3_6="16 17 18";h6=18;;
   00) t1=18;t2=21;ymd=$curdate;datedir=$datnext;h0_3="19 20 21";h3=21;h3_6="22 23 00";h6=00;;
   06) t1=00;t2=03;ymd=$datnext;datedir=$datnext;h0_3="01 02 03";h3=03;h3_6="04 05 06";h6=06;;
   12) t1=06;t2=09;ymd=$datnext;datedir=$datnext;h0_3="07 08 09";h3=09;h3_6="10 11 12";h6=12

  esac

yyyy=` echo $ymd | cut -c1-4 ` 
mm=` echo $ymd | cut -c5-6 ` 
dd=` echo $ymd | cut -c7-8 ` 

ccpa_6hr=$COMOUT.$datedir/$hour

temp_dir=$DATA/ccpa_${datedir}${hour}_03h
if [ -s $temp_dir ]; then
 echo $temp_dir already exists!
else
 mkdir -p $temp_dir
 echo $temp_dir is created !
fi

cd $temp_dir

#--------------------------------------------------------
# Accumulate the first three 1-hourly Stage IV RFC precip
# into 3-hourly
# Accumulate precip (Fortran)
   echo Accumulating precip over 3 hours...
   Num=0
   for HH in $h0_3 
   do
   if [ -s $COMINpcpanl.$yyyy$mm$dd/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2 ]; then
   (( Num=Num+1 ))
    cp -p  $COMINpcpanl.$yyyy$mm$dd/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2 $temp_dir
    $CNVGRIB -g21  $temp_dir/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2  $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h
    cp -p  $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h rfc_01h_${Num}.grb
   else
    echo $COMINpcpanl.$yyyy$mm$dd/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2 does not exist  >>$DATA/warning 
    exit
   fi 
   done
   $EXECccpa/ccpa_accum_1h_files $yyyy $mm $dd $t1                #1a
  if eval test -s rfc_3h.grb 
  then
  mv rfc_3h.grb  rfc_orig_1.grb
   echo Accumulating precip over 3 hours, DONE!
  else
   echo file accumulation failed!!!!
   echo The program will be terminated!!!! 
   export err=9; err_chk
  fi

#---------------------------------------------------------
# Accumulate the second three 1-hourly Stage IV RFC precip
# into 3-hourly
# Accumulate precip (Fortran)
   echo Accumulating precip over 3 hours...
   Num=0
   for HH in $h3_6 
   do
  if [ $HH == 00 ]; then
    if [ -s $COMINpcpanl.$datnext/st4_conus.${datnext}${HH}.01h.grb2 ]; then
    (( Num=Num+1 ))
     cp -p  $COMINpcpanl.$datnext/st4_conus.${datnext}${HH}.01h.grb2 $temp_dir
     $CNVGRIB -g21  $temp_dir/st4_conus.${datnext}${HH}.01h.grb2  $temp_dir/ST4.${datnext}${HH}.01h
     cp -p  $temp_dir/ST4.${datnext}${HH}.01h rfc_01h_${Num}.grb
    else
     echo $COMINpcpanl.$datnext/st4_conus.${datnext}${HH}.01h.grb2 does not exist  >>$DATA/warning 
     exit
    fi 
  else
    if [ -s $COMINpcpanl.$yyyy$mm$dd/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2 ]; then
    (( Num=Num+1 ))
     cp -p  $COMINpcpanl.$yyyy$mm$dd/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2 $temp_dir
     $CNVGRIB -g21  $temp_dir/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2  $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h 
     cp -p  $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h rfc_01h_${Num}.grb
    else
     echo $COMINpcpanl.$yyyy$mm$dd/st4_conus.${yyyy}${mm}${dd}${HH}.01h.grb2 does not exist  >>$DATA/warning 
     exit
    fi 
  fi
   done
   $EXECccpa/ccpa_accum_1h_files $yyyy $mm $dd $t2                #1b
  if eval test -s rfc_3h.grb 
  then
  mv rfc_3h.grb  rfc_orig_2.grb
   echo Accumulating precip over 3 hours, DONE!
  else
   echo file accumulation failed!!!!
   echo The program will be terminated!!!! 
   export err=9; err_chk
  fi

#------------------------------------------------------
# Disaggregate 6-hourly CCPA into 3 hourly based on 3-hourly
# Stage IV accumulation ratios 
#
# Split  6-hourly CCPA into 3-hourly CCPA (Fortran)

  if eval test -s $ccpa_6hr/ccpa.t${hour}z.06h.hrap.conus
  then
  cp $ccpa_6hr/ccpa.t${hour}z.06h.hrap.conus $temp_dir/rfc_scaled_downscaled.grb
  echo Disaggregating into 3-hourly amounts...                         #2     
  $EXECccpa/ccpa_6h_to_3h ${ymd}${t1}0003 ${ymd}${t2}0003  >> $pgmout 2>errfile             
  export err=$?; err_chk
  echo Disaggregation done
  else
   echo $ccpa_6hr/ccpa.t${hour}z.06h.hrap.conus does not exist  >>$DATA/warning
   exit
  fi

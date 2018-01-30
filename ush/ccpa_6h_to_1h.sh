#####!/bin/sh
#!/bin/bash
echo $#

############################################################
#HISTORY:
#09/18/2017: Initial script created by Yan Luo
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
mask_dir=$HOMEccpa/fix

temp_dir=$DATA/ccpa_${datedir}${hour}_01h
if [ -s $temp_dir ]; then
 echo $temp_dir already exists!
 rm -f $temp_dir/*
else
 mkdir -p $temp_dir
 echo $temp_dir is created!
fi

cd $temp_dir

if [ -s $temp_dir/CCPA_CONUS_rfc_mask_hrap.grb ]; then
 echo CCPA_CONUS_rfc_mask_hrap.grb already exists!
else
cp -p $mask_dir/CCPA_CONUS_rfc_mask_hrap.grb $temp_dir/CCPA_CONUS_rfc_mask_hrap.grb
 echo CCPA_CONUS_rfc_mask_hrap.grb is copied!
fi
   Num=0
   for HH in ${h0_6} 
   do
   (( Num=Num+1 ))
   if [ $HH == 00 ]; then
   ymd=$datnext
   yyyy=` echo $ymd | cut -c1-4 `
   mm=` echo $ymd | cut -c5-6 `
   dd=` echo $ymd | cut -c7-8 `
   fi

   if [ -s $COMINpcpanl.$yyyy$mm$dd/ST2ml${yyyy}${mm}${dd}${HH}.Grb.gz ]; then
    cp -p  $COMINpcpanl.$yyyy$mm$dd/ST2ml${yyyy}${mm}${dd}${HH}.Grb.gz $temp_dir
    gunzip $temp_dir/ST2ml${yyyy}${mm}${dd}${HH}.Grb.gz
    cp -p  $temp_dir/ST2ml${yyyy}${mm}${dd}${HH}.Grb rfc2_01h.grb
   else
    echo $COMINpcpanl.$yyyy$mm$dd/ST2ml${yyyy}${mm}${dd}${HH}.Grb.gz does not exist  >>$DATA/warning
    exit
   fi

   if [ -s $COMINpcpanl.$yyyy$mm$dd/ST4.${yyyy}${mm}${dd}${HH}.01h.gz ]; then
    cp -p  $COMINpcpanl.$yyyy$mm$dd/ST4.${yyyy}${mm}${dd}${HH}.01h.gz $temp_dir
    gunzip $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h.gz
    cp -p  $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h rfc4_01h.grb
   else
    echo $COMINpcpanl.$yyyy$mm$dd/ST4.${yyyy}${mm}${dd}${HH}.01h.gz does not exist  >>$DATA/warning
    exit
   fi

#------------------------------------------------------
# Combine hourly Stage IV RFC precip with hourly Stage II RFC precip
#
# Sum of Stage II and Stage IV precip (Fortran)

   if [ $HH == 00 ]; then
   ymd=$curdate
   yyyy=` echo $ymd | cut -c1-4 `
   mm=` echo $ymd | cut -c5-6 `
   dd=` echo $ymd | cut -c7-8 `
   fi

    $EXECccpa/ccpa_comp_st4_st2_1h_files $yyyy $mm $dd $HH                #1
    if eval test -s rfc_1h.grb 
    then
    mv rfc_1h.grb  rfc_orig_${Num}.grb
     echo Combine hourly Stage II and hourly Stage IV precip, DONE!
    else
     echo file Composite of Stage II and Stage IV failed!!!!
     echo The program will be terminated!!!! 
     export err=9; err_chk
    fi
   done

#------------------------------------------------------
# Disaggregate 6-hourly CCPA into hourly based on hourly
# Stage II+IV Composite accumulation ratios 
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

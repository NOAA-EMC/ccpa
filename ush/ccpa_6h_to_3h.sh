#####!/bin/sh
#!/bin/bash
echo $#

############################################################
#HISTORY:
#02/18/2011: Initial script created by Yan Luo
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
datnext=`$nhours +24 $curdate\00 | cut -c1-8`
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

#------------------------------------------------------
# Accumulate 1-hourly Stage II RFC precip into 3-hourly
#
# Accumulate precip (Fortran)
   echo Accumulating precip over 3 hours...
ccpa_6hr=$COMOUT.$datedir/$hour/ccpa
mask_dir=$HOMEccpa/fix

temp_dir=$DATA/ccpa_$datedir$hour
if [ -s $temp_dir ]; then
 echo $temp_dir already exists!
else
 mkdir -p $temp_dir
 echo $temp_dir is created !
fi

cd $temp_dir
$utilscript/setup.sh

cp -p $mask_dir/CCPA_CONUS_rfc_mask_hrap.grb $temp_dir/CCPA_CONUS_rfc_mask_hrap.grb

   Num=0
   for HH in $h0_3 
   do
   if [ -s $COMIN.$yyyy$mm$dd/ST2ml${yyyy}${mm}${dd}${HH}.Grb.Z ]; then
   (( Num=Num+1 ))
    cp -p  $COMIN.$yyyy$mm$dd/ST2ml${yyyy}${mm}${dd}${HH}.Grb.Z $temp_dir
    gunzip $temp_dir/ST2ml${yyyy}${mm}${dd}${HH}.Grb.Z
    cp -p  $temp_dir/ST2ml${yyyy}${mm}${dd}${HH}.Grb rfc_01h_${Num}.grb
   else
    echo $COMIN.$yyyy$mm$dd/ST2ml${yyyy}${mm}${dd}${HH}.Grb.Z does not exist  >>$DATA/warning 
    exit
   fi 
   done
   $EXECccpa/ccpa_accum_1h_files $yyyy $mm $dd $t1                #1a
  if eval test -s rfc_3h.grb 
  then
  mv rfc_3h.grb  rfc2_03h.grb
   echo Accumulating precip over 3 hours, DONE!
  else
   echo file accumulation failed!!!!
   echo The program will be terminated!!!! 
   export err=9; export err; err_chk
  fi

#------------------------------------------------------
# Accumulate 1-hourly Stage IV RFC precip into 3-hourly
#
# Accumulate precip (Fortran)
   echo Accumulating precip over 3 hours...
   Num=0
   for HH in $h0_3 
   do
   if [ -s $COMIN.$yyyy$mm$dd/ST4.${yyyy}${mm}${dd}${HH}.01h.Z ]; then
   (( Num=Num+1 ))
    cp -p  $COMIN.$yyyy$mm$dd/ST4.${yyyy}${mm}${dd}${HH}.01h.Z $temp_dir
    gunzip $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h.Z
    cp -p  $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h rfc_01h_${Num}.grb
   else
    echo $COMIN.$yyyy$mm$dd/ST4.${yyyy}${mm}${dd}${HH}.01h.Z does not exist  >>$DATA/warning 
    exit
   fi 
   done
   $EXECccpa/ccpa_accum_1h_files $yyyy $mm $dd $t1                #1b
  if eval test -s rfc_3h.grb 
  then
  mv rfc_3h.grb  rfc4_03h.grb
   echo Accumulating precip over 3 hours, DONE!
  else
   echo file accumulation failed!!!!
   echo The program will be terminated!!!! 
   export err=9; err_chk
  fi

#------------------------------------------------------
# Combine 3-hourly Stage IV RFC precip with 3-hourly Stage II RFC precip
#
# Sum of Stage II and Stage IV precip (Fortran)
   $EXECccpa/ccpa_comp_st4_st2_3h_files $yyyy $mm $dd $t1                #2
  if eval test -s rfc_3h.grb 
  then
  mv rfc_3h.grb  rfc_orig_1.grb
   echo Combine Stage II and Stage IV precip over 3 hours, DONE!
  else
   echo file Composite of Stage II and Stage IV failed!!!!
   echo The program will be terminated!!!! 
   export err=9; err_chk
  fi

  mv rfc4_03h.grb rfc4_03h.1.grb
  mv rfc2_03h.grb rfc2_03h.1.grb

   Num=0
   for HH in $h3_6 
   do
  if [ $HH == 00 ]; then
    if [ -s $COMIN.$datnext/ST2ml${datnext}${HH}.Grb.Z ]; then
    (( Num=Num+1 ))
     cp -p  $COMIN.$datnext/ST2ml${datnext}${HH}.Grb.Z $temp_dir
     gunzip $temp_dir/ST2ml${datnext}${HH}.Grb.Z
     cp -p  $temp_dir/ST2ml${datnext}${HH}.Grb rfc_01h_${Num}.grb
    else
     echo $COMIN.$datnext/ST2ml${datnext}${HH}.Grb.Z does not exist  >>$DATA/warning 
     exit
    fi 
  else
    if [ -s $COMIN.$yyyy$mm$dd/ST2ml${yyyy}${mm}${dd}${HH}.Grb.Z ]; then
    (( Num=Num+1 ))
     cp -p  $COMIN.$yyyy$mm$dd/ST2ml${yyyy}${mm}${dd}${HH}.Grb.Z $temp_dir
     gunzip $temp_dir/ST2ml${yyyy}${mm}${dd}${HH}.Grb.Z
     cp -p  $temp_dir/ST2ml${yyyy}${mm}${dd}${HH}.Grb rfc_01h_${Num}.grb
    else
     echo $COMIN.$yyyy$mm$dd/ST2ml${yyyy}${mm}${dd}${HH}.Grb.Z does not exist  >>$DATA/warning 
     exit
    fi 
  fi
   done
   $EXECccpa/ccpa_accum_1h_files $yyyy $mm $dd $t2                #3a
  if eval test -s rfc_3h.grb 
  then
  mv rfc_3h.grb  rfc2_03h.grb
   echo Accumulating precip over 3 hours, DONE!
  else
   echo file accumulation failed!!!!
   echo The program will be terminated!!!! 
   export err=9; err_chk
  fi

#------------------------------------------------------
# Accumulate 1-hourly Stage IV RFC precip into 3-hourly
#
# Accumulate precip (Fortran)
   echo Accumulating precip over 3 hours...
   Num=0
   for HH in $h3_6 
   do
  if [ $HH == 00 ]; then
    if [ -s $COMIN.$datnext/ST4.${datnext}${HH}.01h.Z ]; then
    (( Num=Num+1 ))
     cp -p  $COMIN.$datnext/ST4.${datnext}${HH}.01h.Z $temp_dir
     gunzip $temp_dir/ST4.${datnext}${HH}.01h.Z
     cp -p  $temp_dir/ST4.${datnext}${HH}.01h rfc_01h_${Num}.grb
    else
     echo $COMIN.$datnext/ST4.${datnext}${HH}.01h.Z does not exist  >>$DATA/warning 
     exit
    fi 
  else
    if [ -s $COMIN.$yyyy$mm$dd/ST4.${yyyy}${mm}${dd}${HH}.01h.Z ]; then
    (( Num=Num+1 ))
     cp -p  $COMIN.$yyyy$mm$dd/ST4.${yyyy}${mm}${dd}${HH}.01h.Z $temp_dir
     gunzip $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h.Z
     cp -p  $temp_dir/ST4.${yyyy}${mm}${dd}${HH}.01h rfc_01h_${Num}.grb
    else
     echo $COMIN.$yyyy$mm$dd/ST4.${yyyy}${mm}${dd}${HH}.01h.Z does not exist  >>$DATA/warning 
     exit
    fi 
  fi
   done
   $EXECccpa/ccpa_accum_1h_files $yyyy $mm $dd $t2                #3b
  if eval test -s rfc_3h.grb 
  then
  mv rfc_3h.grb  rfc4_03h.grb
   echo Accumulating precip over 3 hours, DONE!
  else
   echo file accumulation failed!!!!
   echo The program will be terminated!!!! 
   export err=9; err_chk
  fi

#------------------------------------------------------
# Combine 3-hourly Stage IV RFC precip with 3-hourly Stage II RFC precip
#
# Sum of Stage II and Stage IV precip (Fortran)
   $EXECccpa/ccpa_comp_st4_st2_3h_files $yyyy $mm $dd $t2                #4
  if eval test -s rfc_3h.grb 
  then
  mv rfc_3h.grb   rfc_orig_2.grb
   echo Combine Stage II and Stage IV precip over 3 hours, DONE!
  else
   echo file Composite of Stage II and Stage IV failed!!!!
   echo The program will be terminated!!!! 
   export err=9; err_chk
  fi

  mv rfc4_03h.grb rfc4_03h.2.grb
  mv rfc2_03h.grb rfc2_03h.2.grb

#------------------------------------------------------
# Disaggregate 6-hourly CCPA into 3 hourly based on 3-hourly
# Stage II+IV Composite accumulation ratios 
#
# Split  6-hourly CCPA into 3-hourly CCPA (Fortran)

  if eval test -s $ccpa_6hr/ccpa_conus_hrap_t${hour}z_06h
  then
  cp $ccpa_6hr/ccpa_conus_hrap_t${hour}z_06h $temp_dir/rfc_scaled_downscaled.grb 
  echo Disaggregating into 3-hourly amounts...                         #5     
  $EXECccpa/ccpa_6h_to_3h ${ymd}${t1}0003 ${ymd}${t2}0003  >> $pgmout 2>errfile             
  export err=$?; err_chk
  echo Disaggregation done
  else
   echo $ccpa_6hr/ccpa_conus_hrap_t${hour}z_06h does not exist  >>$DATA/warning 
   exit
  fi

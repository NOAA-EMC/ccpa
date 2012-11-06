#!/usr/bin/sh
set -x 

echo $#

############################################################
#HISTORY:
#01/04/2010: Initial script created by Mike Charles in 2008
#01/04/2010: Script accepted by Dingchen Hou for CCPA initial implementation
#03/24/2010: Script slightly  modified by Dingchen Hou for CCPA initial implementation
############################################################
#----------------------------------------------------------
# Begginning and ending dates
if (( $# > 0 )); then
  date=$1
else
  echo 'argument(s) required yyyymmdd '
  exit
fi
yyyy=` echo $date | cut -c1-4 ` 
mm=` echo $date | cut -c5-6 ` 
dd=` echo $date | cut -c7-8 ` 
#
#------------------------------------------------------
# Accumulate 6-hourly RFC precip into daily
#
# Accumulate precip (Fortran)
   echo Accumulating precip over 24 hours...

   for HH in 06 12 18 24
   do
   if [ -s rfc_ST4/rfc_orig_$HH.grb ]; then
    (( Num=HH/6 ))
    cp -pr rfc_ST4/rfc_orig_$HH.grb rfc_06h_$Num.grb
   else
    echo rfc_ST4/rfc_orig_$HH.grb Does not exist, check $work_dir/$date 
    exit
   fi 
   done
  $EXECccpa/ccpa_accum_6h_files $yyyy $mm $dd 12               #3
  if eval test -s rfc_24h.grb
  then
   echo Accumulating precip over 24 hours, DONE!
  else
   echo file accumulation failed!!!!
   echo The program will be terminated!!!! 
   export err=9
   err_chk
  fi
 
#------------------------------------------------------
# Prepare for scaling program (Fortran)
#
# Interpolate RFC grid to 1/8th deg
  echo Interpolating 24-hour RFC grib to 1/8th deg...
  $USHccpa/ccpa_copygb_pcp.sh $interp 8thd rfc_24h                       #4
# Alpha and beta grids
  if eval test -f a.bin -f b.bin -f mask_0125deg.bin
  then
   echo Coefficient files a.bin and b.bin and mask_0125deg.bin are available!
  else
   echo Coefficient files a.bin and/or b.bin and/or mask_0125deg.bin Unavailable!
   echo The program will be terminated. 
   exit
  fi
#------------------------------------------------------	
# Run RFC scaling executable (Fortran 90)
#
  echo Scaling RFC precip by a b grids...
  $EXECccpa/ccpa_scale_rfc rfc_24h_8thd.grb a.bin b.bin rfc_24h_8thd_scld.grb      #5
  if eval test -s rfc_24h_8thd_scld.grb
  then
   echo  Scaling Done!!!
  else
   echo Scaling failed!!!!
   echo The program will be terminated!!!! 
   export err=9; export err; err_chk
  fi

#Interpolate RFC scaled  data back to higher resolution (HRAP or NDFD) grid
  echo Interpolating RFC_scaled to $grid grid and preparing for downscaling...
  $USHccpa/ccpa_copygb_pcp.sh $interp $grid rfc_24h_8thd_scld        #6d

#------------------------------------------------------
# Compute RFC at NDFD resolution with information loss
#
  if [ $grid == hrap ]; then 
     mv -f rfc_24h.grb rfc_24h_hrap.grb      
  else 
     $USHccpa/ccpa_copygb_pcp.sh $interp $grid rfc_24h                       #6a
  fi
     $USHccpa/ccpa_copygb_pcp.sh $interp 8thd rfc_24h_${grid}                #6b
     $USHccpa/ccpa_copygb_pcp.sh $interp $grid rfc_24h_${grid}_8thd            #6c

#------------------------------------------------------
# Run RFC downscaling executable (Fortran 90)
#
  echo Downscaling RFC precip, i.e. restoring high-res info...               #6e
  $EXECccpa/ccpa_downscale rfc_24h_8thd_scld_${grid}.grb rfc_24h_${grid}.grb rfc_24h_${grid}_8thd_${grid}.grb rfc_scaled_downscaled.grb
  if eval test -f rfc_scaled_downscaled.grb
  then
     echo  "Downscaling Done!!!"
  else
     echo "Downscaling Failed!!!"
     export err=9; err_chk
  fi
#
#------------------------------------------------------
# Disaggregate into 6-hourly RFC precip (Fortran)
#
## interpolate original 6hr precip to the target grid
  if [ $grid == hrap ]; then 
     mv -f rfc_06h_1.grb rfc_orig_1.grb      
     mv -f rfc_06h_2.grb rfc_orig_2.grb      
     mv -f rfc_06h_3.grb rfc_orig_3.grb      
     mv -f rfc_06h_4.grb rfc_orig_4.grb      
  else
     $USHccpa/ccpa_copygb_pcp.sh $interp $grid rfc_06h_1     #7
     $USHccpa/ccpa_copygb_pcp.sh $interp $grid rfc_06h_2     #7
     $USHccpa/ccpa_copygb_pcp.sh $interp $grid rfc_06h_3     #7
     $USHccpa/ccpa_copygb_pcp.sh $interp $grid rfc_06h_4     #7
     mv rfc_06h.1_${grid}.grb rfc.orig.1.grb
     mv rfc_06h.2_${grid}.grb rfc.orig.2.grb
     mv rfc_06h.3_${grid}.grb rfc.orig.3.grb
     mv rfc_06h.4_${grid}.grb rfc.orig.4.grb
  fi

  echo Disaggregating into 6-hourly amounts...                 #8
  $EXECccpa/ccpa_daily_to_6h ${date}120006 ${date}120612 ${date}121218 ${date}121824 >> $pgmout 2>errfile
  export err=$?; err_chk
  echo Disaggregation done
#
#------------------------------------------------------
# Move files to output directory
#
  echo Moving 6-hour grids to output directory...
  mv -f rfc_adjusted_6hr.1.grb $out_dir/rfc_adjusted_6hr_${grid}.1.grb
  mv -f rfc_adjusted_6hr.2.grb $out_dir/rfc_adjusted_6hr_${grid}.2.grb
  mv -f rfc_adjusted_6hr.3.grb $out_dir/rfc_adjusted_6hr_${grid}.3.grb
  mv -f rfc_adjusted_6hr.4.grb $out_dir/rfc_adjusted_6hr_${grid}.4.grb
#
  echo Moving done!!!
